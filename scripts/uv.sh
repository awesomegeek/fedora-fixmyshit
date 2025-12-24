#!/bin/bash

# uv (Astral) installation script for Fedora 43
# Installs uv using the official installer (user-local, default: ~/.local/bin/uv)

set -e  # Exit on error

echo "=========================================="
echo "Installing uv (Astral)"
echo "=========================================="

# Ensure curl exists
if command -v curl >/dev/null 2>&1; then
    echo "curl already installed, skipping..."
else
    echo "Installing curl..."
    sudo dnf install -y curl
fi

if command -v uv >/dev/null 2>&1; then
    echo "uv already installed, skipping..."
    return 0
fi

# Official installer
# Ref: https://docs.astral.sh/uv/getting-started/installation/
echo "Installing uv via official installer..."

# Best-effort: ensure ~/.local/bin exists
mkdir -p "$HOME/.local/bin"

curl -LsSf https://astral.sh/uv/install.sh | sh

# Verify
if command -v uv >/dev/null 2>&1; then
    echo ""
    uv --version || true
    echo "✅ uv installation complete!"
else
    echo "uv was not found on PATH after installation."
    echo "If uv installed to ~/.local/bin, ensure it's in your PATH and re-login."
    return 1
fi