# Interpreter Selection Design

This document details the design and implementation of Termi's shell interpreter selection system.

## Overview

Termi's interpreter selection system provides users with flexible options for choosing their shell:
- Automatic detection of available shells
- Interactive menu selection
- Custom path input
- Persistent preference storage
- Configuration override capability

## Design Goals

1. **Comprehensive Detection**: Find all available shells on the system
2. **User-Friendly Selection**: Simple, intuitive interface
3. **Flexibility**: Support both menu selection and custom paths
4. **Persistence**: Remember user preferences
5. **Portability**: Work across different platforms (Linux, macOS, Windows)

## Detection Algorithm

### Phase 1: Standard System Paths

Termi first checks standard system directories where shells are typically installed:

**Linux/Unix:**
- `/bin/bash`, `/usr/bin/bash`
- `/bin/zsh`, `/usr/bin/zsh`
- `/bin/sh`, `/usr/bin/sh`
- `/bin/fish`, `/usr/bin/fish`
- `/bin/tcsh`, `/usr/bin/tcsh`
- `/bin/csh`, `/usr/bin/csh`
- `/bin/ksh`, `/usr/bin/ksh`
- `/bin/dash`, `/usr/bin/dash`

**macOS:**
- All Unix paths above
- `/opt/homebrew/bin/bash` (Apple Silicon Homebrew)
- `/opt/homebrew/bin/zsh`
- `/opt/homebrew/bin/fish`
- `/usr/local/bin/bash` (Intel Homebrew)
- `/usr/local/bin/zsh`
- `/usr/local/bin/fish`

**Windows:**
- `C:\Program Files\Git\bin\bash.exe`
- `C:\Windows\System32\cmd.exe`
- `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`

### Phase 2: PATH Environment Scan

Termi scans all directories in the `PATH` environment variable for common shell names:

```go
shellNames := []string{
    "bash", "zsh", "fish", "sh", 
    "dash", "ksh", "tcsh", "csh",
}
```

For each directory in PATH, Termi checks if any of these shell names exist and are executable.

### Phase 3: Deduplication

After collecting all potential shells, Termi removes duplicates to avoid showing the same shell multiple times.

### Phase 4: Executable Verification

Each detected shell is verified to ensure:
- The file exists
- The file is a regular file (not a directory)
- The file has executable permissions
- The shell can be invoked (basic functionality test)

## Selection Interface

### Menu Display

The selection menu displays shells in a numbered list:

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

### Input Handling

Termi accepts two types of input:

**1. Number Selection:**
- User types a number (1, 2, 3, etc.)
- Termi validates the number is within range
- Returns the corresponding shell path

**2. Custom Path:**
- User types any file path
- Termi validates the path exists and is executable
- Returns the validated path

**3. Invalid Input:**
- If input is neither a valid number nor valid path
- Termi displays an error message
- Prompts the user again

## Configuration System

### Configuration File

**Location:** `~/.shelloptions.termioptions`

**Format:** Plain text, one shell path per line

**Example:**
```
/usr/bin/zsh
```

### Loading Configuration

1. Read `~/.shelloptions.termioptions`
2. Check for `#ignoreoption` flag
3. If flag present, ignore configuration
4. Otherwise, read the first non-comment, non-empty line
5. Validate the shell path
6. Use the shell if valid

### Saving Configuration

When a user selects a shell from the menu:
1. Create/update `~/.shelloptions.termioptions`
2. Write the selected shell path
3. Set file permissions to 0644

### Ignore Option

Users can temporarily disable configuration by adding `#ignoreoption`:

```
#ignoreoption
/usr/bin/zsh
```

This is useful for:
- Testing different shells
- Temporary configuration changes
- Debugging selection issues

## Implementation Details

### Shell Structure

```go
type Shell struct {
    Path string  // Full path to the shell
    Name string  // Base name (e.g., "bash")
}
```

### Detection Function

```go
func DetectAvailable() ([]Shell, error) {
    // 1. Check standard paths
    // 2. Check platform-specific paths
    // 3. Scan PATH environment
    // 4. Deduplicate results
    // 5. Verify executability
    return shells, nil
}
```

### Selection Function

```go
func PromptSelection(shells []Shell) string {
    // 1. Display menu
    // 2. Read user input
    // 3. Parse input (number or path)
    // 4. Validate selection
    // 5. Return selected path
}
```

### Validation Function

```go
func Validate(path string) error {
    // 1. Check path is not empty
    // 2. Check file exists
    // 3. Check file is executable
    // 4. Test shell invocation
    return nil
}
```

## Platform-Specific Considerations

### Linux

- Checks `DISPLAY` and `WAYLAND_DISPLAY` for GUI detection
- Supports multiple terminal emulators
- Uses standard Unix paths
- Respects systemd user sessions

### macOS

- Includes Homebrew paths (both Intel and Apple Silicon)
- Uses AppleScript for Terminal.app integration
- Supports iTerm2
- Always assumes GUI environment is available

### Windows

- Handles Windows path separators (`\` vs `/`)
- Supports Git Bash, PowerShell, CMD
- Checks for WSL installations
- Uses `start` command for GUI mode

## Error Handling

### No Shells Found

If no shells are detected:
1. Display error message
2. Exit with non-zero status
3. Suggest installing a shell

### Invalid Selection

If user provides invalid input:
1. Display error message
2. Re-prompt for selection
3. Allow retry

### Configuration Error

If configuration file cannot be read:
1. Display warning
2. Continue with default behavior
3. Prompt for shell selection

### Shell Validation Failure

If selected shell is invalid:
1. Display error message
2. Re-prompt for selection
3. Allow retry

## Performance Considerations

### Detection Speed

Shell detection is designed to be fast:
- File system checks are cached where possible
- Parallel checks could be implemented (currently sequential)
- PATH scanning is limited to common shell names

### Startup Impact

Detection runs only when:
- No configuration exists
- Configuration is ignored
- Configuration is invalid

Otherwise, the saved shell path is used directly.

## Security Considerations

### Path Validation

All shell paths are validated before use:
- File existence check
- Executable permission check
- Basic functionality test

### User Input

User input is treated as potentially untrusted:
- Paths are validated before use
- No arbitrary code execution
- No privilege escalation

### Configuration File

Configuration file is stored in user home directory:
- User has full control
- No sensitive data stored
- Plain text format for transparency

## Future Enhancements

### Potential Improvements

1. **Caching**: Cache detected shells for faster startup
2. **Parallel Detection**: Detect shells in parallel
3. **Shell Metadata**: Display shell versions in menu
4. **Custom Paths**: Allow users to add custom search paths
5. **Shell Profiles**: Save multiple shell profiles
6. **Priority System**: Rank shells by preference

### Extended Features

1. **Shell Testing**: Test shell capabilities before selection
2. **Compatibility Check**: Verify shell compatibility with Termi
3. **Shell Recommendations**: Recommend shells based on usage
4. **Shell Installation**: Offer to install missing shells
5. **Shell Configuration**: Integrate with shell configuration files

## Testing

### Unit Tests

Test individual functions:
- `DetectAvailable()`
- `Validate()`
- `PromptSelection()`

### Integration Tests

Test the complete flow:
- Configuration loading
- Shell detection
- User selection
- Configuration saving

### Platform Tests

Test on each platform:
- Linux (various distributions)
- macOS (Intel and Apple Silicon)
- Windows (various versions)

## Examples

### Basic Usage

```bash
$ termi
Available shell interpreters:
============================
1. bash (/usr/bin/bash)
2. zsh (/usr/bin/zsh)
3. fish (/usr/bin/fish)

Select a shell by number, or enter a custom path:
> 2
Launching embedded terminal with shell: /usr/bin/zsh
```

### Custom Path

```bash
$ termi
Available shell interpreters:
============================
1. bash (/usr/bin/bash)
2. zsh (/usr/bin/zsh)

Select a shell by number, or enter a custom path:
> /opt/homebrew/bin/bash
Launching embedded terminal with shell: /opt/homebrew/bin/bash
```

### With Configuration

```bash
$ cat ~/.shelloptions.termioptions
/usr/bin/zsh

$ termi
Launching embedded terminal with shell: /usr/bin/zsh
```

### With Ignore Option

```bash
$ cat ~/.shelloptions.termioptions
#ignoreoption
/usr/bin/zsh

$ termi
Configuration temporarily ignored (#ignoreoption set)
Available shell interpreters:
============================
1. bash (/usr/bin/bash)
2. zsh (/usr/bin/zsh)
...
```

## Resources

- [POSIX Shell Specification](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sh.html)
- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Zsh Manual](https://zsh.sourceforge.io/Doc/)
- [Fish Documentation](https://fishshell.com/docs/current/)
- [Termi Repository](https://github.com/live-by-unix/termi)
