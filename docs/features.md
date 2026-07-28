# Feature Documentation

This document provides detailed explanations of each Termi feature.

## Table of Contents

1. [Plugin System](#plugin-system)
2. [Ubuntu-Style Terminal](#ubuntu-style-terminal)
3. [Runtime Interpreter Selection](#runtime-interpreter-selection)
4. [Persistent Shell Preference](#persistent-shell-preference)
5. [Dual Launch Modes](#dual-launch-modes)

---

## Plugin System

### Overview

The plugin system allows you to extend Termi's functionality by placing executable scripts in the `~/.term-plugins/` directory. These scripts are automatically executed when Termi launches, before the shell interpreter is selected.

### How It Works

1. Termi checks for the existence of `~/.term-plugins/`
2. If the directory exists, Termi scans for executable files
3. Each executable file is executed in order
4. Plugin output is displayed to the user
5. Execution continues even if a plugin fails

### Plugin Detection

A file is considered a plugin if:
- It is a regular file (not a directory)
- It has executable permissions (`chmod +x`)
- It is located in `~/.term-plugins/`

### Supported Languages

Plugins can be written in any language. Termi automatically detects the interpreter:

**By Shebang:**
```bash
#!/bin/bash
#!/usr/bin/env python3
#!/usr/bin/node
```

**By File Extension:**
- `.sh` → `/bin/sh`
- `.bash` → `/bin/bash`
- `.zsh` → `/bin/zsh`
- `.py` → `python3`
- `.js` → `node`

### Plugin Examples

**Welcome Message Plugin:**
```bash
#!/bin/bash
echo "Welcome to Termi!"
echo "System: $(uname -s)"
echo "Date: $(date)"
```

**Environment Setup Plugin:**
```bash
#!/bin/bash
export EDITOR=vim
export PAGER=less
echo "Environment variables set"
```

**Python Plugin:**
```python
#!/usr/bin/env python3
import os
print(f"Python version: {os.sys.version}")
print("Plugin executed successfully")
```

### Best Practices

- Keep plugins lightweight and fast
- Use descriptive filenames
- Include error handling
- Test plugins before deployment
- Document plugin dependencies

### Troubleshooting

**Plugins not executing:**
- Verify executable permissions: `ls -la ~/.term-plugins/`
- Check file permissions: `chmod +x ~/.term-plugins/your-script`
- Review Termi output for error messages

**Plugin execution errors:**
- Test plugin manually: `~/.term-plugins/your-script`
- Check shebang line
- Verify interpreter is installed

---

## Ubuntu-Style Terminal

### Overview

Termi provides an Ubuntu-style terminal experience with color highlighting, command execution, and familiar usability.

### Features

**Color Highlighting:**
- Syntax highlighting for commands
- Color-coded output
- Readable color scheme

**Command Execution:**
- Full shell command support
- Command history
- Tab completion (via shell)

**Baseline Usability:**
- Familiar keybindings
- Standard terminal behavior
- Compatible with existing shell configurations

### Terminal Emulation

Termi uses the system's terminal emulator for GUI mode and process replacement for embedded mode, ensuring compatibility with:

- ANSI escape sequences
- Terminal resizing
- Mouse support (when available)
- Unicode characters

### Customization

Terminal appearance can be customized through:
- Shell configuration files (`.bashrc`, `.zshrc`)
- Terminal emulator settings (in GUI mode)
- Environment variables (`TERM`, `COLORTERM`)

---

## Runtime Interpreter Selection

### Overview

Termi automatically detects all available shell interpreters on your system and presents an interactive selection menu.

### Detection Algorithm

1. **Standard Paths Check:**
   - `/bin`, `/usr/bin`
   - Common shells: bash, zsh, fish, sh, dash, ksh, tcsh, csh

2. **Platform-Specific Paths:**
   - macOS: `/opt/homebrew/bin`, `/usr/local/bin`
   - Windows: Git Bash, PowerShell, CMD paths

3. **PATH Environment Scan:**
   - Scans all directories in `$PATH`
   - Checks for common shell names

4. **Executable Verification:**
   - File existence check
   - Executable permission verification
   - Basic functionality test

### Selection Menu

```
Available shell interpreters:
============================
1. bash (/usr/bin/bash)
2. zsh (/usr/bin/zsh)
3. fish (/usr/bin/fish)
4. dash (/usr/bin/dash)

Select a shell by number, or enter a custom path:
> 
```

### Selection Methods

**By Number:**
- Type the menu number (1, 2, 3, etc.)
- Quick and easy for common shells

**By Custom Path:**
- Type any valid shell path
- Useful for shells not in the menu
- Path is validated before use

### Shell Validation

Before using a shell, Termi verifies:
- File exists and is executable
- Shell can be invoked
- Basic functionality (version check)

### Supported Shells

Termi supports any POSIX-compliant shell, including:
- bash, zsh, fish
- sh, dash, ksh
- tcsh, csh
- PowerShell (Windows)
- CMD (Windows)

---

## Persistent Shell Preference

### Overview

Termi remembers your preferred shell interpreter through the `~/.shelloptions.termioptions` configuration file.

### Configuration File Format

**Basic Configuration:**
```
/usr/bin/zsh
```

**With Comments:**
```
# My preferred shell
/usr/bin/zsh
```

**Ignore Option:**
```
#ignoreoption
/usr/bin/zsh
```

### Configuration Loading

1. Termi reads `~/.shelloptions.termioptions`
2. Checks for `#ignoreoption` flag
3. If not ignored, reads the shell path
4. Validates the shell path
5. Uses the shell if valid

### Ignore Option

Add `#ignoreoption` to temporarily disable configuration:

```
#ignoreoption
/usr/bin/zsh
```

This is useful for:
- Testing different shells
- Temporary configuration changes
- Debugging shell selection issues

### Configuration Persistence

When you select a shell from the menu, Termi automatically:
- Updates `~/.shelloptions.termioptions`
- Saves your selection
- Uses it on subsequent launches

To disable automatic saving, create the config file manually with `#ignoreoption`.

### Configuration Location

- **File:** `~/.shelloptions.termioptions`
- **Permissions:** 0644 (read/write for owner)
- **Format:** Plain text, one shell path per line

---

## Dual Launch Modes

### Overview

Termi can be launched in two distinct modes: GUI mode and embedded mode.

### GUI Mode

Launches Termi as a standalone terminal window:

```bash
termi --gui
```

**Behavior:**
- Opens new terminal window
- Runs selected shell in new window
- Original shell remains unaffected
- Automatic GUI detection

**Platform Support:**
- **Linux:** gnome-terminal, xterm, konsole, xfce4-terminal, etc.
- **macOS:** Terminal.app, iTerm2
- **Windows:** cmd.exe, PowerShell

**Automatic Detection:**
Termi automatically uses GUI mode if:
- `DISPLAY` environment variable is set (Linux)
- `WAYLAND_DISPLAY` is set (Wayland)
- Running on macOS
- `--gui` flag is explicitly set

### Embedded Mode

Runs Termi inside the current shell instance:

```bash
termi
```

**Behavior:**
- Replaces current process with selected shell
- Runs in same terminal window
- Seamless transition
- Type `exit` to return

**Implementation:**
Uses `syscall.Exec()` to replace the current process, ensuring:
- No additional overhead
- Same process ID
- Preserved environment
- Clean process tree

### Mode Selection

**Automatic:**
```bash
termi
```
- Detects environment
- Chooses appropriate mode

**Explicit GUI:**
```bash
termi --gui
```
- Forces GUI mode

**Explicit Embedded:**
```bash
termi --shell /bin/bash
```
- Uses embedded mode (default)

### Use Cases

**GUI Mode:**
- Opening new terminal windows
- Running separate sessions
- Desktop integration

**Embedded Mode:**
- Shell replacement
- Script integration
- Quick shell switching

### Troubleshooting

**GUI mode fails:**
- Verify terminal emulator is installed
- Check `DISPLAY` environment variable
- Try embedded mode as fallback

**Embedded mode issues:**
- Ensure shell path is valid
- Check file permissions
- Verify shell is executable
