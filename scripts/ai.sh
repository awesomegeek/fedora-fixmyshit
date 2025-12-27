#!/bin/bash

# AI Tooling installation script for Fedora 43
# Installs: OpenCode (opencode.ai)

set -e  # Exit on error

echo "=========================================="
echo "Installing AI Tooling"
echo "=========================================="

# Install OpenCode
if command -v opencode >/dev/null 2>&1; then
    echo "OpenCode already installed, skipping..."
else
    echo "Installing OpenCode..."
    # Ensure curl is available
    if ! command -v curl >/dev/null 2>&1; then
        sudo dnf install -y curl
    fi
    
    curl -fsSL https://opencode.ai/install | bash
fi

if command -v opencode >/dev/null 2>&1; then
    echo ""
    echo "✅ AI Tooling installation complete!"
else
    echo "opencode binary not found after installation."
    # Some installers might put things in ~/.local/bin or similar
    if [ -f "$HOME/.local/bin/opencode" ]; then
        echo "Found opencode in ~/.local/bin. Ensure it is in your PATH."
        echo "✅ AI Tooling installation complete!"
    else
        return 1
    fi
fi
