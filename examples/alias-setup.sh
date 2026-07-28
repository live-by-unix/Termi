#!/bin/bash
# Plugin: Alias Setup
# Description: Sets common aliases for better terminal experience
# Author: LIVE-BU-UNIX

# Only set aliases for bash and zsh
if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
    # List aliases
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
    alias ls='ls --color=auto'
    
    # Grep aliases
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    
    # Safety aliases
    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'
    
    # Navigation aliases
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    
    # Git aliases (if git is installed)
    if command -v git &> /dev/null; then
        alias gs='git status'
        alias ga='git add'
        alias gc='git commit'
        alias gp='git push'
        alias gl='git log --oneline'
        alias gd='git diff'
    fi
    
    echo "Aliases configured"
else
    echo "Skipping alias setup (not running bash or zsh)"
fi
