package shell

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
)

// Shell represents a detected shell interpreter
type Shell struct {
	Path string
	Name string
}

// DetectAvailable finds all available shell interpreters on the system
func DetectAvailable() ([]Shell, error) {
	var shells []Shell

	// Common shell paths to check
	commonPaths := []string{
		"/bin/bash",
		"/usr/bin/bash",
		"/bin/zsh",
		"/usr/bin/zsh",
		"/bin/sh",
		"/usr/bin/sh",
		"/bin/fish",
		"/usr/bin/fish",
		"/bin/tcsh",
		"/usr/bin/tcsh",
		"/bin/csh",
		"/usr/bin/csh",
		"/bin/ksh",
		"/usr/bin/ksh",
		"/bin/dash",
		"/usr/bin/dash",
	}

	// Add Homebrew paths for macOS
	if runtime.GOOS == "darwin" {
		commonPaths = append(commonPaths,
			"/opt/homebrew/bin/bash",
			"/opt/homebrew/bin/zsh",
			"/opt/homebrew/bin/fish",
			"/usr/local/bin/bash",
			"/usr/local/bin/zsh",
			"/usr/local/bin/fish",
		)
	}

	// Add Windows paths if applicable
	if runtime.GOOS == "windows" {
		commonPaths = append(commonPaths,
			"C:\\Program Files\\Git\\bin\\bash.exe",
			"C:\\Windows\\System32\\cmd.exe",
			"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
		)
	}

	// Check each path
	for _, path := range commonPaths {
		if isExecutable(path) {
			name := filepath.Base(path)
			// Remove .exe on Windows
			name = strings.TrimSuffix(name, ".exe")
			shells = append(shells, Shell{
				Path: path,
				Name: name,
			})
		}
	}

	// Also check shells in PATH
	pathEnv := os.Getenv("PATH")
	if pathEnv != "" {
		pathDirs := filepath.SplitList(pathEnv)
		shellNames := []string{"bash", "zsh", "fish", "sh", "dash", "ksh", "tcsh", "csh"}
		
		for _, shellName := range shellNames {
			for _, dir := range pathDirs {
				fullPath := filepath.Join(dir, shellName)
				if isExecutable(fullPath) {
					// Check if already in list
					alreadyExists := false
					for _, s := range shells {
						if s.Path == fullPath {
							alreadyExists = true
							break
						}
					}
					if !alreadyExists {
						shells = append(shells, Shell{
							Path: fullPath,
							Name: shellName,
						})
					}
				}
			}
		}
	}

	return shells, nil
}

// isExecutable checks if a file exists and is executable
func isExecutable(path string) bool {
	info, err := os.Stat(path)
	if err != nil {
		return false
	}

	// On Unix-like systems, check executable bit
	if runtime.GOOS != "windows" {
		return info.Mode().Perm()&0111 != 0
	}

	// On Windows, just check if it exists and is a regular file
	return !info.IsDir()
}

// PromptSelection displays a menu for shell selection and returns the chosen path
func PromptSelection(shells []Shell) string {
	if len(shells) == 0 {
		return ""
	}

	fmt.Println("Available shell interpreters:")
	fmt.Println("============================")
	
	for i, shell := range shells {
		fmt.Printf("%d. %s (%s)\n", i+1, shell.Name, shell.Path)
	}
	
	fmt.Println("\nSelect a shell by number, or enter a custom path:")
	fmt.Print("> ")

	reader := bufio.NewReader(os.Stdin)
	input, err := reader.ReadString('\n')
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading input: %v\n", err)
		return ""
	}

	input = strings.TrimSpace(input)
	
	// Check if input is a number
	var selection int
	if _, err := fmt.Sscanf(input, "%d", &selection); err == nil {
		// Number selection
		if selection >= 1 && selection <= len(shells) {
			return shells[selection-1].Path
		}
		fmt.Println("Invalid selection")
		return PromptSelection(shells)
	}

	// Treat as custom path
	if input != "" {
		if isExecutable(input) {
			return input
		}
		fmt.Printf("Path '%s' is not executable\n", input)
		return PromptSelection(shells)
	}

	return ""
}

// Validate checks if a shell path is valid and executable
func Validate(path string) error {
	if path == "" {
		return fmt.Errorf("shell path is empty")
	}

	if !isExecutable(path) {
		return fmt.Errorf("shell path is not executable: %s", path)
	}

	// Try to run the shell with --version to verify it works
	cmd := exec.Command(path, "--version")
	if err := cmd.Run(); err != nil {
		// Some shells don't support --version, try -V
		cmd = exec.Command(path, "-V")
		if err := cmd.Run(); err != nil {
			// If both fail, still consider it valid if it's executable
			// (some shells just don't have version flags)
		}
	}

	return nil
}
