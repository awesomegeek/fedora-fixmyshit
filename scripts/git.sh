#!/bin/bash

# Git configuration script (global) for Fedora 43

set -e  # Exit on error

echo "=========================================="
echo "Configuring Git"
echo "=========================================="

# Ensure git is available
if rpm -q git >/dev/null 2>&1; then
    echo "Git already installed, skipping..."
else
    echo "Installing Git..."
    sudo dnf install -y git
fi

# Ensure vim is available (for default editor)
# Fedora package provides /usr/bin/vim
if command -v vim >/dev/null 2>&1; then
    echo "Vim already installed, skipping..."
else
    echo "Installing Vim..."
    sudo dnf install -y vim-enhanced
fi

email="naingtunwin@gmail.com"
name="AwesomeGeek"

current_email="$(git config --global --get user.email || true)"
current_name="$(git config --global --get user.name || true)"
current_editor="$(git config --global --get core.editor || true)"

if [ "$current_email" = "$email" ]; then
    echo "Git user.email already set, skipping..."
else
    echo "Setting git user.email to: $email"
    git config --global user.email "$email"
fi

if [ "$current_name" = "$name" ]; then
    echo "Git user.name already set, skipping..."
else
    echo "Setting git user.name to: $name"
    git config --global user.name "$name"
fi

if [ "$current_editor" = "vim" ]; then
    echo "Git core.editor already set to vim, skipping..."
else
    echo "Setting git core.editor to vim"
    git config --global core.editor "vim"
fi

echo ""
echo "✅ Git configuration complete!"