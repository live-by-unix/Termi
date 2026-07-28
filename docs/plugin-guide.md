# Plugin Development Guide

This guide explains how to create and develop plugins for Termi.

## What is a Plugin?

A plugin is any executable script placed in the `~/.term-plugins/` directory. Termi automatically executes all plugins in this directory at launch, before the shell interpreter is selected.

## Plugin Basics

### Location

All plugins must be placed in:
```
~/.term-plugins/
```

### Requirements

A valid plugin must:
- Be a regular file (not a directory)
- Have executable permissions (`chmod +x`)
- Be located in `~/.term-plugins/`

### Execution Order

Plugins are executed in alphabetical order by filename. Use numeric prefixes if order matters:
```
01-env-setup.sh
02-alias-setup.sh
03-welcome.sh
```

## Creating Your First Plugin

### Step 1: Create the Plugin Directory

```bash
mkdir -p ~/.term-plugins
```

### Step 2: Create a Plugin Script

```bash
cat > ~/.term-plugins/welcome.sh << 'EOF'
#!/bin/bash
echo "Welcome to Termi!"
echo "Current date: $(date)"
EOF
```

### Step 3: Make It Executable

```bash
chmod +x ~/.term-plugins/welcome.sh
```

### Step 4: Test It

```bash
~/.term-plugins/welcome.sh
```

### Step 5: Run Termi

```bash
termi
```

You should see the welcome message when Termi launches.

## Plugin Languages

Termi supports plugins written in any language. The interpreter is detected automatically.

### Bash

```bash
#!/bin/bash
echo "Bash plugin executed"
export MY_VAR="hello"
```

### Python

```python
#!/usr/bin/env python3
print("Python plugin executed")
import os
os.environ['MY_VAR'] = 'hello'
```

### Node.js

```javascript
#!/usr/bin/env node
console.log("Node.js plugin executed")
process.env.MY_VAR = 'hello'
```

### Zsh

```zsh
#!/usr/bin/zsh
echo "Zsh plugin executed"
export MY_VAR="hello"
```

### Perl

```perl
#!/usr/bin/perl
print "Perl plugin executed\n";
$ENV{'MY_VAR'} = 'hello';
```

### Ruby

```ruby
#!/usr/bin/env ruby
puts "Ruby plugin executed"
ENV['MY_VAR'] = 'hello'
```

## Interpreter Detection

Termi uses two methods to determine the interpreter:

### 1. Shebang Line

The shebang (first line of the script) specifies the interpreter:

```bash
#!/bin/bash
#!/usr/bin/env python3
#!/usr/local/bin/node
```

### 2. File Extension

If no shebang is present, Termi uses the file extension:

- `.sh` → `/bin/sh`
- `.bash` → `/bin/bash`
- `.zsh` → `/bin/zsh`
- `.py` → `python3`
- `.js` → `node`

## Plugin Examples

### Environment Setup

```bash
#!/bin/bash
# ~/.term-plugins/env-setup.sh

export EDITOR=vim
export VISUAL=vim
export PAGER=less
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "Environment variables configured"
```

### Alias Setup

```bash
#!/bin/bash
# ~/.term-plugins/alias-setup.sh

# Create a temporary file with aliases
alias_file=$(mktemp)

cat > "$alias_file" << 'ALIASES'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
ALIASES

# Source the aliases (works for bash/zsh)
if [ -n "$BASH_VERSION" ]; then
    source "$alias_file"
elif [ -n "$ZSH_VERSION" ]; then
    source "$alias_file"
fi

rm "$alias_file"

echo "Aliases configured"
```

### Git Configuration

```bash
#!/bin/bash
# ~/.term-plugins/git-setup.sh

if command -v git &> /dev/null; then
    git config --global core.editor "vim"
    git config --global init.defaultBranch "main"
    git config --global pull.rebase false
    echo "Git configuration updated"
else
    echo "Git not found, skipping configuration"
fi
```

### System Information

```bash
#!/bin/bash
# ~/.term-plugins/system-info.sh

echo "=== System Information ==="
echo "OS: $(uname -s)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "=========================="
```

### Network Check

```bash
#!/bin/bash
# ~/.term-plugins/network-check.sh

if ping -c 1 8.8.8.8 &> /dev/null; then
    echo "Network: Connected"
else
    echo "Network: Disconnected"
fi
```

### Python Environment

```python
#!/usr/bin/env python3
# ~/.term-plugins/python-env.py

import sys
import os

print(f"Python version: {sys.version}")
print(f"Python executable: {sys.executable}")

# Set Python environment variables
os.environ['PYTHONIOENCODING'] = 'utf-8'

# Check for common packages
packages = ['numpy', 'pandas', 'requests']
for package in packages:
    try:
        __import__(package)
        print(f"✓ {package} is installed")
    except ImportError:
        print(f"✗ {package} is not installed")
```

### Docker Check

```bash
#!/bin/bash
# ~/.term-plugins/docker-check.sh

if command -v docker &> /dev/null; then
    echo "Docker: Installed ($(docker --version))"
    if docker info &> /dev/null; then
        echo "Docker daemon: Running"
    else
        echo "Docker daemon: Not running"
    fi
else
    echo "Docker: Not installed"
fi
```

## Advanced Plugin Techniques

### Conditional Execution

```bash
#!/bin/bash
# Only run on Linux
if [ "$(uname)" != "Linux" ]; then
    echo "Skipping Linux-specific plugin"
    exit 0
fi

# Plugin code here
```

### Error Handling

```bash
#!/bin/bash
set -e  # Exit on error

# Plugin code here
echo "This will execute"

# If this fails, the plugin stops
false  # This will cause the plugin to fail

echo "This will not execute"
```

### Logging

```bash
#!/bin/bash

LOG_FILE="$HOME/.term-plugins/plugin.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "Plugin started"
# Plugin code here
log "Plugin finished"
```

### User Interaction

```bash
#!/bin/bash

# Ask user for input
read -p "Enter your name: " name
echo "Hello, $name!"
```

### Plugin Dependencies

```bash
#!/bin/bash

# Check for required commands
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: $1 is not installed"
        exit 1
    fi
}

check_command "curl"
check_command "jq"

# Plugin code that uses curl and jq
```

## Best Practices

### 1. Keep Plugins Lightweight

Plugins run every time Termi launches. Keep them fast:

```bash
# Good: Simple check
if [ -f "$HOME/.config/myapp/config" ]; then
    echo "Config found"
fi

# Bad: Long-running operation
# This will slow down Termi startup
sleep 5
```

### 2. Use Descriptive Filenames

```bash
# Good
01-env-setup.sh
02-alias-setup.sh
03-welcome.sh

# Bad
plugin1.sh
script.sh
test.sh
```

### 3. Handle Errors Gracefully

```bash
#!/bin/bash

# Good: Handle errors
if ! command -v git &> /dev/null; then
    echo "Git not found, skipping"
    exit 0
fi

# Bad: Assume git exists
git config --global ...
```

### 4. Document Your Plugins

```bash
#!/bin/bash
# Plugin: Git Configuration
# Description: Sets default git preferences
# Author: Your Name
# Version: 1.0

# Plugin code here
```

### 5. Test Plugins Individually

```bash
# Test before deploying
~/.term-plugins/your-plugin.sh
```

### 6. Use Idempotent Operations

```bash
# Good: Safe to run multiple times
mkdir -p "$HOME/.config/myapp"

# Bad: Will fail if directory exists
mkdir "$HOME/.config/myapp"
```

## Troubleshooting

### Plugin Not Executing

**Check permissions:**
```bash
ls -la ~/.term-plugins/
```

**Make executable:**
```bash
chmod +x ~/.term-plugins/your-plugin.sh
```

**Check Termi output:**
```bash
termi 2>&1 | grep -i plugin
```

### Plugin Fails Silently

**Test manually:**
```bash
~/.term-plugins/your-plugin.sh
```

**Check for errors:**
```bash
bash -x ~/.term-plugins/your-plugin.sh
```

### Wrong Interpreter Used

**Check shebang:**
```bash
head -n1 ~/.term-plugins/your-plugin.sh
```

**Use full path:**
```bash
#!/usr/bin/env python3
```

### Plugin Too Slow

**Profile execution time:**
```bash
time ~/.term-plugins/your-plugin.sh
```

**Optimize or remove heavy operations**

## Plugin Templates

### Basic Template

```bash
#!/bin/bash
# Plugin: [Name]
# Description: [Description]
# Author: [Your Name]

# Main plugin code
echo "Plugin executed"
```

### Python Template

```python
#!/usr/bin/env python3
"""
Plugin: [Name]
Description: [Description]
Author: [Your Name]
"""

def main():
    print("Plugin executed")

if __name__ == "__main__":
    main()
```

### Node.js Template

```javascript
#!/usr/bin/env node
/**
 * Plugin: [Name]
 * Description: [Description]
 * Author: [Your Name]
 */

console.log("Plugin executed");
```

## Sharing Plugins

You can share your plugins by:

1. **Creating a GitHub repository** with your plugins
2. **Documenting installation** in your README
3. **Providing examples** and usage instructions
4. **Including tests** if applicable

Example repository structure:
```
termi-plugins/
├── README.md
├── plugins/
│   ├── env-setup.sh
│   ├── alias-setup.sh
│   └── welcome.sh
└── install.sh
```

## Resources

- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)
- [Python Documentation](https://docs.python.org/3/)
- [Node.js Documentation](https://nodejs.org/docs/)
- [Termi Repository](https://github.com/live-by-unix/termi)
