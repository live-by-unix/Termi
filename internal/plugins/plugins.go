package plugins

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// Execute runs all scripts in the plugin directory
func Execute(pluginDir string) error {
	// Check if plugin directory exists
	info, err := os.Stat(pluginDir)
	if err != nil {
		if os.IsNotExist(err) {
			// Plugin directory doesn't exist, that's fine
			return nil
		}
		return fmt.Errorf("cannot access plugin directory: %w", err)
	}

	if !info.IsDir() {
		return fmt.Errorf("plugin path is not a directory: %s", pluginDir)
	}

	// Read directory contents
	entries, err := os.ReadDir(pluginDir)
	if err != nil {
		return fmt.Errorf("cannot read plugin directory: %w", err)
	}

	// Execute each executable file
	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}

		pluginPath := filepath.Join(pluginDir, entry.Name())
		
		// Check if file is executable
		info, err := entry.Info()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Cannot get info for %s: %v\n", entry.Name(), err)
			continue
		}

		// Check executable permission
		if info.Mode().Perm()&0111 == 0 {
			// Not executable, skip
			continue
		}

		// Execute the plugin
		if err := executePlugin(pluginPath); err != nil {
			fmt.Fprintf(os.Stderr, "Plugin %s failed: %v\n", entry.Name(), err)
		} else {
			fmt.Printf("Plugin %s executed successfully\n", entry.Name())
		}
	}

	return nil
}

// executePlugin runs a single plugin script
func executePlugin(path string) error {
	// Determine the interpreter based on file extension or shebang
	var cmd *exec.Cmd
	
	// Read first few bytes to check for shebang
	file, err := os.Open(path)
	if err != nil {
		return err
	}
	defer file.Close()

	buf := make([]byte, 2)
	if _, err := file.Read(buf); err != nil {
		return err
	}

	// Check for shebang
	if string(buf) == "#!" {
		// Read the full shebang line
		file.Seek(0, 0)
		shebangLine := make([]byte, 128)
		n, _ := file.Read(shebangLine)
		shebangLine = shebangLine[:n]
		
		parts := strings.Fields(string(shebangLine))
		if len(parts) > 1 {
			// Shebang with interpreter (e.g., #!/bin/bash)
			interpreter := strings.TrimPrefix(parts[0], "#!")
			args := parts[1:]
			cmd = exec.Command(interpreter, append(args, path)...)
		} else if len(parts) == 1 {
			// Simple shebang (e.g., #!/bin/bash)
			interpreter := strings.TrimPrefix(parts[0], "#!")
			cmd = exec.Command(interpreter, path)
		} else {
			// Invalid shebang, try direct execution
			cmd = exec.Command(path)
		}
	} else {
		// No shebang, try to determine by extension
		ext := strings.ToLower(filepath.Ext(path))
		switch ext {
		case ".sh":
			cmd = exec.Command("/bin/sh", path)
		case ".bash":
			cmd = exec.Command("/bin/bash", path)
		case ".zsh":
			cmd = exec.Command("/bin/zsh", path)
		case ".py":
			cmd = exec.Command("python3", path)
		case ".js":
			cmd = exec.Command("node", path)
		default:
			// Try direct execution
			cmd = exec.Command(path)
		}
	}

	// Set environment
	cmd.Env = os.Environ()
	cmd.Stdin = nil
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}
