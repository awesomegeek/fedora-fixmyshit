#!/bin/bash

# Rust installation script (rustup)
# Ref: https://www.rust-lang.org/learn/get-started/

set -e  # Exit on error

echo "=========================================="
echo "Installing Rust (rustup)"
echo "=========================================="

# Ensure curl exists
if command -v curl >/dev/null 2>&1; then
    echo "curl already installed, skipping..."
else
    echo "Installing curl..."
    sudo dnf install -y curl
fi

# Idempotency: if rustup is already installed, we consider Rust set up.
if command -v rustup >/dev/null 2>&1; then
    echo "rustup already installed, skipping..."
else
    echo "Installing rustup (stable toolchain)..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# Load cargo env for this run
if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.cargo/env"
fi

# Ensure toolchain exists (best-effort)
if command -v rustup >/dev/null 2>&1; then
    rustup toolchain install stable >/dev/null 2>&1 || true
    rustup default stable >/dev/null 2>&1 || true
fi

if command -v rustc >/dev/null 2>&1; then
    rustc --version || true
fi
if command -v cargo >/dev/null 2>&1; then
    cargo --version || true
fi

echo ""
echo "✅ Rust installation complete!"