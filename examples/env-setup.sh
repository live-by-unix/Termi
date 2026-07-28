#!/bin/bash
# Plugin: Environment Setup
# Description: Sets common environment variables
# Author: LIVE-BY-UNIX

# Set default editor
export EDITOR=vim
export VISUAL=vim

# Set pager
export PAGER=less
export LESS="-R"

# Set language
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set timezone (adjust as needed)
export TZ=America/New_York

# Add common paths to PATH (if not already present)
[[ ":$PATH:" != *":/usr/local/bin:"* ]] && export PATH="/usr/local/bin:$PATH"
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"

echo "Environment variables configured"
