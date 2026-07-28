# Termi

A next-generation terminal application with extensibility, runtime interpreter selection, and dual launch modes.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Go Version](https://img.shields.io/badge/Go-1.18+-00ADD8?logo=go)](https://golang.org)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos%20%7C%20windows-lightgrey)](https://github.com/live-by-unix/termi)

## Overview

Termi is a modern terminal emulator that bridges the gap between traditional CLI tools and GUI applications. Built with Go, it offers a clean, extensible architecture with powerful features for both developers and power users.

**Author:** LIVE-BY-UNIX  
**Repository:** https://github.com/live-by-unix/termi  
**Year:** 2026  
**License:** MIT

## Features

### 1. Plugin System (`.term-plugins/`)
Termi supports a powerful plugin system. Any executable scripts placed in the `~/.term-plugins/` directory are automatically executed at launch. This allows you to:
- Set up custom environment variables
- Run initialization scripts
- Load custom configurations
- Execute startup commands

Plugins are detected by their executable permission and can be written in any language (bash, Python, JavaScript, etc.).

### 2. Ubuntu-Style Terminal
Termi provides an out-of-the-box terminal experience with:
- Color highlighting for better readability
- Full command execution capabilities
- Baseline usability with familiar keybindings
- Support for common terminal features

### 3. Runtime Interpreter Selection
Termi automatically scans for all available shell interpreters on your system and presents them in an interactive menu:

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

You can select by number or type a custom path directly. Termi detects shells from:
- Standard system paths (`/bin`, `/usr/bin`)
- Homebrew installations on macOS (`/opt/homebrew/bin`, `/usr/local/bin`)
- Your system's PATH environment variable
- Windows-specific paths (Git Bash, PowerShell, CMD)

### 4. Persistent Shell Preference
Termi remembers your preferred shell interpreter via the `~/.shelloptions.termioptions` configuration file. Simply set your preferred shell path in this file:

```bash
# ~/.shelloptions.termioptions
/usr/bin/zsh
```

To temporarily ignore the configuration, add `#ignoreoption`:

```bash
# ~/.shelloptions.termioptions
#ignoreoption
/usr/bin/zsh
```

### 5. Dual Launch Modes
Termi can be launched in two modes:

**GUI Mode:** Launches as a standalone terminal window
```bash
termi --gui
```

**Embedded Mode:** Runs inside your current shell instance
```bash
termi
```

Termi automatically detects your environment and chooses the appropriate mode, but you can override this with the `--gui` flag.

## Installation

### Quick Install (No Sudo)

Use the cargo-style installer that doesn't require sudo privileges:

```bash
curl -fsSL https://raw.githubusercontent.com/live-by-unix/termi/main/scripts/install-no-sudo.sh | bash
```

### System-Wide Install (With Sudo)

For a system-wide installation:

```bash
curl -fsSL https://raw.githubusercontent.com/live-by-unix/termi/main/scripts/install-sudo.sh | sudo bash
```

### Manual Installation

1. Download the latest release from the [releases page](https://github.com/live-by-unix/termi/releases)
2. Extract the archive
3. Move the binary to your PATH:

```bash
# Linux/macOS
tar -xzf termi-1.0.0-linux-amd64.tar.gz
sudo mv termi /usr/local/bin/

# Windows
# Extract termi-1.0.0-windows-amd64.zip and add to PATH
```

### Build from Source

```bash
git clone https://github.com/live-by-unix/termi.git
cd termi
go build -o termi .
sudo mv termi /usr/local/bin/
```

## Usage

### Basic Usage

Launch Termi with automatic shell detection:
```bash
termi
```

Launch in GUI mode:
```bash
termi --gui
```

Specify a shell directly:
```bash
termi --shell /usr/bin/zsh
```

Show version information:
```bash
termi --version
```

### Setting Up Plugins

Create the plugins directory and add your scripts:

```bash
mkdir -p ~/.term-plugins

# Create a sample plugin
cat > ~/.term-plugins/welcome.sh << 'EOF'
#!/bin/bash
echo "Welcome to Termi!"
echo "Current date: $(date)"
EOF

chmod +x ~/.term-plugins/welcome.sh
```

### Configuring Default Shell

Create or edit `~/.shelloptions.termioptions`:
```bash
echo "/usr/bin/zsh" > ~/.shelloptions.termioptions
```

To temporarily ignore the config:
```bash
echo "#ignoreoption" > ~/.shelloptions.termioptions
```

## Examples

See the `examples/` directory for sample plugin scripts:

- `welcome.sh` - A simple welcome message plugin
- `env-setup.sh` - Environment variable configuration
- `alias-setup.sh` - Custom alias definitions

## Documentation

Detailed documentation is available in the `docs/` directory:

- [Feature Documentation](docs/features.md) - In-depth explanations of each feature
- [Developer Notes](docs/developer-notes.md) - Architecture and development guide
- [Plugin Development Guide](docs/plugin-guide.md) - How to create plugins
- [Interpreter Selection Design](docs/interpreter-selection.md) - Shell detection algorithm

## Uninstallation

### No-Sudo Installation

```bash
~/.local/bin/termi --remove
```

Or manually:
```bash
rm ~/.local/bin/termi
rm ~/.shelloptions.termioptions
rm -rf ~/.term-plugins
```

### Sudo Installation

```bash
sudo /usr/local/bin/termi --remove
```

Or manually:
```bash
sudo rm /usr/local/bin/termi
rm ~/.shelloptions.termioptions
rm -rf ~/.term-plugins
```

## Version Pinning

Install a specific version:

```bash
curl -fsSL https://raw.githubusercontent.com/live-by-unix/termi/main/scripts/install-no-sudo.sh | bash -s -- v1.2.0
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Development

### Project Structure

```
termi/
├── main.go              # Entry point
├── go.mod               # Go module definition
├── go.sum               # Dependency checksums
├── internal/            # Internal packages
│   ├── config/         # Configuration management
│   ├── plugins/        # Plugin system
│   ├── shell/          # Shell detection and selection
│   └── terminal/       # Terminal launching logic
├── docs/               # Documentation
├── scripts/            # Installation scripts
├── examples/           # Example plugins
└── releases/           # Pre-built binaries
```

### Building

Build for current platform:
```bash
go build -o termi .
```

Build for all platforms:
```bash
./scripts/build-all.sh
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

Copyright (c) 2026 LIVE-BY-UNIX

## Support

- **Issues:** https://github.com/live-by-unix/termi/issues
- **Discussions:** https://github.com/live-by-unix/termi/discussions
- **Email:** support@termi.dev

## Acknowledgments

Built with Go and the amazing open-source community.
