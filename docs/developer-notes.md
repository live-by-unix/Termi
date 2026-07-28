# Developer Notes

This document provides technical details for developers working on Termi.

## Architecture

### Project Structure

```
termi/
├── main.go              # Application entry point
├── go.mod               # Go module definition
├── go.sum               # Dependency checksums
├── internal/            # Internal packages
│   ├── config/         # Configuration management
│   │   └── config.go   # Config loading/saving
│   ├── plugins/        # Plugin system
│   │   └── plugins.go  # Plugin execution
│   ├── shell/          # Shell detection
│   │   └── shell.go    # Shell detection and selection
│   └── terminal/       # Terminal launching
│       └── terminal.go # GUI and embedded modes
├── docs/               # Documentation
├── scripts/            # Installation scripts
├── examples/           # Example plugins
└── releases/           # Pre-built binaries
```

### Package Overview

**main.go**
- Command-line flag parsing
- Configuration initialization
- Plugin execution
- Shell selection orchestration
- Terminal mode selection

**internal/config**
- Configuration file management
- Shell preference persistence
- Ignore option handling

**internal/plugins**
- Plugin directory scanning
- Executable detection
- Interpreter detection (shebang/extension)
- Plugin execution

**internal/shell**
- Shell path detection
- Platform-specific paths
- Interactive menu system
- Shell validation

**internal/terminal**
- GUI terminal launching
- Embedded mode execution
- Process replacement
- Platform-specific terminal emulators

## Design Decisions

### Go Module Structure

Termi uses a standard Go module structure with internal packages to:
- Encapsulate implementation details
- Prevent external imports of internal packages
- Maintain clean separation of concerns

### Configuration Format

The configuration file uses a simple plain-text format:
- One shell path per line
- Comments with `#`
- Special `#ignoreoption` flag

This format was chosen for:
- Simplicity and readability
- Easy manual editing
- No external dependencies
- Human-friendly

### Plugin System

The plugin system uses:
- File system scanning for discovery
- Executable permission checking
- Shebang/extension-based interpreter detection
- Sequential execution

Design considerations:
- No plugin registry or manifest
- Convention over configuration
- Language-agnostic
- Fail-safe execution (continues on errors)

### Shell Detection

Shell detection uses a multi-pass approach:
1. Standard system paths check
2. Platform-specific paths (Homebrew, Windows)
3. PATH environment variable scan
4. Executable verification

This ensures maximum compatibility while maintaining performance.

### Terminal Launching

**GUI Mode:**
- Detects available terminal emulators
- Uses platform-specific commands
- Falls back to embedded mode on failure

**Embedded Mode:**
- Uses `syscall.Exec()` for process replacement
- Preserves environment and process ID
- Seamless shell switching

## Development Workflow

### Setting Up Development Environment

```bash
# Clone repository
git clone https://github.com/live-by-unix/termi.git
cd termi

# Install dependencies (none required for stdlib-only code)
go mod download

# Build
go build -o termi .

# Run
./termi
```

### Testing

```bash
# Run tests (when implemented)
go test ./...

# Run tests with coverage
go test -cover ./...

# Run specific package tests
go test ./internal/config
```

### Building

```bash
# Build for current platform
go build -o termi .

# Build with optimization
go build -ldflags="-s -w" -o termi .

# Build for specific platform
GOOS=linux GOARCH=amd64 go build -o termi-linux-amd64 .
```

### Cross-Compilation

```bash
# Linux AMD64
GOOS=linux GOARCH=amd64 go build -o termi-linux-amd64 .

# Linux ARM64
GOOS=linux GOARCH=arm64 go build -o termi-linux-arm64 .

# macOS AMD64
GOOS=darwin GOARCH=amd64 go build -o termi-darwin-amd64 .

# macOS ARM64 (Apple Silicon)
GOOS=darwin GOARCH=arm64 go build -o termi-darwin-arm64 .

# Windows AMD64
GOOS=windows GOARCH=amd64 go build -o termi-windows-amd64.exe .

# Windows ARM64
GOOS=windows GOARCH=arm64 go build -o termi-windows-arm64.exe .
```

## Code Style Guidelines

### Formatting

- Use `gofmt` for consistent formatting
- Follow standard Go conventions
- Maximum line length: 120 characters
- Use tabs for indentation

### Naming

- Package names: lowercase, single word
- Exported functions: PascalCase
- Internal functions: camelCase
- Constants: PascalCase for exported, camelCase for internal
- Interfaces: PascalCase, often ending in "er"

### Error Handling

- Always handle errors explicitly
- Use `fmt.Errorf` for error wrapping
- Provide context in error messages
- Avoid silent error swallowing

### Comments

- Document exported functions, types, and constants
- Use godoc format
- Comment complex logic
- Keep comments concise and accurate

## Performance Considerations

### Startup Time

Termi is designed for fast startup:
- Minimal dependencies
- Lazy loading where possible
- Efficient file system operations
- No unnecessary blocking

### Memory Usage

- Small memory footprint
- No long-running processes in embedded mode
- Clean process tree
- Efficient string handling

### Plugin Execution

- Plugins run sequentially
- No parallel execution (to maintain order)
- Timeout considerations for long-running plugins

## Platform-Specific Notes

### Linux

- Supports multiple terminal emulators
- Checks `DISPLAY` and `WAYLAND_DISPLAY`
- Uses standard Unix paths
- Supports systemd user sessions

### macOS

- Homebrew paths included
- Uses AppleScript for Terminal.app
- Supports iTerm2
- Always assumes GUI available

### Windows

- Supports Git Bash, PowerShell, CMD
- Uses `start` command for GUI mode
- Handles Windows path separators
- Checks for WSL installations

## Security Considerations

### Plugin Execution

- Plugins run with user permissions
- No sandboxing (by design)
- Users should trust plugins before installation
- Executable permission required

### Configuration

- Config file in user home directory
- No sensitive data stored
- Plain text format
- File permissions: 0644

### Shell Execution

- Shells run with user permissions
- No privilege escalation
- Validates shell paths
- Prevents arbitrary code execution

## Future Enhancements

### Potential Features

- Plugin dependency management
- Plugin marketplace
- Configuration profiles
- Shell session management
- Terminal multiplexing integration
- Custom themes
- Plugin hot-reloading

### Technical Improvements

- Add comprehensive test suite
- Implement benchmarking
- Add telemetry (opt-in)
- Improve error messages
- Add debug mode
- Plugin sandboxing option

## Contributing

### Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests (when applicable)
5. Update documentation
6. Submit pull request

### Code Review Checklist

- Code follows style guidelines
- Tests pass (when applicable)
- Documentation updated
- No breaking changes (unless intended)
- Commit messages are clear

### Issue Reporting

- Use GitHub Issues
- Provide detailed reproduction steps
- Include platform and Go version
- Attach error logs if available

## Resources

- [Go Documentation](https://golang.org/doc/)
- [Effective Go](https://golang.org/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Termi Repository](https://github.com/live-by-unix/termi)
