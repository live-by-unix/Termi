package terminal

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strings"
	"syscall"
)

// LaunchGUI launches Termi as a standalone GUI application
func LaunchGUI(shellPath string) error {
	// For GUI mode, we'll use a simple approach:
	// Launch the shell in a new terminal emulator window
	
	var terminalCmd string
	var terminalArgs []string

	switch runtime.GOOS {
	case "linux":
		// Try common Linux terminal emulators
		terminals := []struct {
			cmd  string
			args []string
		}{
			{"gnome-terminal", []string{"--"}},
			{"xterm", []string{"-e"}},
			{"konsole", []string{"-e"}},
			{"xfce4-terminal", []string{"-e"}},
			{"mate-terminal", []string{"-x"}},
			{"lxterminal", []string{"-e"}},
		}

		for _, term := range terminals {
			if _, err := exec.LookPath(term.cmd); err == nil {
				terminalCmd = term.cmd
				terminalArgs = append(term.args, shellPath)
				break
			}
		}

		if terminalCmd == "" {
			return fmt.Errorf("no suitable terminal emulator found")
		}

	case "darwin":
		// On macOS, use Terminal.app or iTerm2
		// Check for iTerm2 first
		if _, err := exec.LookPath("iterm2"); err == nil {
			terminalCmd = "iterm2"
			terminalArgs = []string{"--", shellPath}
		} else {
			// Use Apple Terminal
			terminalCmd = "osascript"
			terminalArgs = []string{
				"-e",
				fmt.Sprintf(`tell application "Terminal" to do script "%s"`, shellPath),
			}
		}

	case "windows":
		// On Windows, use the default terminal or conhost
		terminalCmd = "cmd"
		terminalArgs = []string{"/c", "start", shellPath}

	default:
		return fmt.Errorf("unsupported operating system: %s", runtime.GOOS)
	}

	cmd := exec.Command(terminalCmd, terminalArgs...)
	cmd.Stdin = nil
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Start(); err != nil {
		return fmt.Errorf("failed to launch terminal: %w", err)
	}

	fmt.Printf("Launched GUI terminal with shell: %s\n", shellPath)
	return nil
}

// LaunchEmbedded launches Termi embedded in the current shell
func LaunchEmbedded(shellPath string) error {
	// For embedded mode, we replace the current process with the selected shell
	// This makes Termi run "inside" the current shell instance
	
	fmt.Printf("Launching embedded terminal with shell: %s\n", shellPath)
	fmt.Println("Type 'exit' to return to your original shell.")

	// Prepare the shell command
	args := []string{shellPath}
	
	// Add login flag for better experience
	if strings.Contains(shellPath, "bash") || strings.Contains(shellPath, "zsh") {
		args = append(args, "-l")
	} else if strings.Contains(shellPath, "sh") {
		args = append(args, "-l")
	}

	// Replace current process with the shell
	return syscall.Exec(shellPath, args, os.Environ())
}

// RunCommand executes a single command in the specified shell
func RunCommand(shellPath, command string) error {
	cmd := exec.Command(shellPath, "-c", command)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

// StartInteractive starts an interactive shell session
func StartInteractive(shellPath string) error {
	cmd := exec.Command(shellPath)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
