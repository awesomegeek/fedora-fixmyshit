#!/bin/bash

# Go (Golang) installation script for Fedora 43

set -e  # Exit on error

echo "=========================================="
echo "Installing Go (Golang)"
echo "=========================================="

# Install Go from Fedora repos
if rpm -q golang >/dev/null 2>&1; then
    echo "Go package already installed, skipping..."
else
    echo "Installing Go..."
    sudo dnf install -y golang
fi

if command -v go >/dev/null 2>&1; then
    echo ""
    go version || true
    echo "✅ Go installation complete!"
else
    echo "go binary not found after installation."
    return 1
fi