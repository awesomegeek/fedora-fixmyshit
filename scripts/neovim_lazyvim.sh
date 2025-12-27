#!/bin/bash

# Neovim + LazyVim Installation and Configuration Script for Fedora 43

set -e  # Exit on error

echo "=========================================="
echo "Installing Neovim + LazyVim"
echo "=========================================="

# Install packages required for a good LazyVim experience
# - ripgrep/fd: core fuzzy-finding/search tools
# - gcc/make: Tree-sitter parsers and native builds
# - git: plugin manager + starter repo
required_pkgs=(
    neovim
    git
    ripgrep
    fd-find
    gcc
    gcc-c++
    make
    curl
)

missing_pkgs=()
for pkg in "${required_pkgs[@]}"; do
    if rpm -q "$pkg" >/dev/null 2>&1; then
        :
    else
        missing_pkgs+=("$pkg")
    fi
done

if [ ${#missing_pkgs[@]} -eq 0 ]; then
    echo "Required packages already installed, skipping..."
else
    echo "Installing packages: ${missing_pkgs[*]}"
    sudo dnf install -y "${missing_pkgs[@]}"
fi

if ! command -v nvim >/dev/null 2>&1; then
    echo "Neovim binary not found after installation."
    return 1
fi

NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

# If an existing config exists, back it up so the script is safe to re-run.
if [ -d "$NVIM_DIR" ] && [ -n "$(ls -A "$NVIM_DIR" 2>/dev/null || true)" ]; then
    # Consider it already installed if Neovim config looks present.
    if [ -f "$NVIM_DIR/lua/config/lazy.lua" ] && [ -f "$NVIM_DIR/lazy-lock.json" ]; then
        echo "Neovim config already present in $NVIM_DIR, skipping config install..."
    else
        backup_dir="${NVIM_DIR}.backup.$(date +%Y%m%d%H%M%S)"
        echo "Existing Neovim config detected. Backing up to: $backup_dir"
        mv "$NVIM_DIR" "$backup_dir"
    fi
fi

if [ ! -d "$NVIM_DIR" ]; then
    echo "Installing Neovim config from awesomegeek/nvim into: $NVIM_DIR"
    mkdir -p "$(dirname "$NVIM_DIR")"
    git clone https://github.com/awesomegeek/nvim "$NVIM_DIR"
fi

# Pre-install plugins/headless sync (best effort; don't fail the whole rig if it errors)
# The first run may take a while.
echo "Running Neovim headless plugin sync (best effort)..."
set +e
nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1
set -e

echo ""
echo "✅ Neovim + LazyVim installation complete!"
echo ""
echo "Next: run 'nvim' to finish any first-run setup."