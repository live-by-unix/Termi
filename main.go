package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"runtime"

	"github.com/live-by-unix/termi/internal/config"
	"github.com/live-by-unix/termi/internal/plugins"
	"github.com/live-by-unix/termi/internal/shell"
	"github.com/live-by-unix/termi/internal/terminal"
)

const (
	Version = "1.0.0"
	Author  = "LIVE-BY-UNIX"
)

var (
	guiMode    = flag.Bool("gui", false, "Launch in GUI mode")
	shellPath  = flag.String("shell", "", "Override shell interpreter path")
	version    = flag.Bool("version", false, "Show version information")
)

func main() {
	flag.Parse()

	if *version {
		fmt.Printf("Termi v%s\n", Version)
		fmt.Printf("Author: %s\n", Author)
		fmt.Printf("Repository: https://github.com/live-by-unix/termi\n")
		os.Exit(0)
	}

	// Initialize configuration
	cfg, err := config.Load()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Warning: Could not load config: %v\n", err)
		cfg = config.Default()
	}

	// Check if config is ignored
	if cfg.IgnoreOption {
		fmt.Println("Configuration temporarily ignored (#ignoreoption set)")
	}

	// Execute plugins from .term-plugins/ directory
	homeDir, err := os.UserHomeDir()
	if err == nil {
		pluginDir := filepath.Join(homeDir, ".term-plugins")
		if err := plugins.Execute(pluginDir); err != nil {
			fmt.Fprintf(os.Stderr, "Plugin execution error: %v\n", err)
		}
	}

	// Determine shell to use
	selectedShell := *shellPath

	// Always show selection menu unless --shell flag is provided
	// This ensures users can choose their shell each time
	if selectedShell == "" {
		shells, err := shell.DetectAvailable()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error detecting shells: %v\n", err)
			os.Exit(1)
		}

		if len(shells) == 0 {
			fmt.Fprintf(os.Stderr, "No shells found on system\n")
			os.Exit(1)
		}

		selectedShell = shell.PromptSelection(shells)
		if selectedShell == "" {
			fmt.Println("No shell selected")
			os.Exit(1)
		}

		// Save selection to config for reference, but won't auto-use next time
		cfg.ShellPath = selectedShell
		if err := config.Save(cfg); err != nil {
			fmt.Fprintf(os.Stderr, "Warning: Could not save config: %v\n", err)
		}
	}

	// Launch terminal
	if *guiMode || isGUIEnvironment() {
		if err := terminal.LaunchGUI(selectedShell); err != nil {
			fmt.Fprintf(os.Stderr, "GUI launch failed: %v\n", err)
			// Fallback to embedded mode
			if err := terminal.LaunchEmbedded(selectedShell); err != nil {
				fmt.Fprintf(os.Stderr, "Embedded launch failed: %v\n", err)
				os.Exit(1)
			}
		}
	} else {
		if err := terminal.LaunchEmbedded(selectedShell); err != nil {
			fmt.Fprintf(os.Stderr, "Embedded launch failed: %v\n", err)
			os.Exit(1)
		}
	}
}

// isGUIEnvironment detects if we're in a GUI environment
func isGUIEnvironment() bool {
	// Check for common GUI environment variables
	if os.Getenv("DISPLAY") != "" {
		return true
	}
	if os.Getenv("WAYLAND_DISPLAY") != "" {
		return true
	}
	
	// On macOS, we almost always have a GUI
	if runtime.GOOS == "darwin" {
		return true
	}
	
	return false
}
