#!/bin/bash

# Node.js installation via NVM (Node Version Manager)
# Ref: https://github.com/nvm-sh/nvm

set -e  # Exit on error

echo "=========================================="
echo "Installing Node.js via NVM"
echo "=========================================="

# Helpers
is_sourced() {
    [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

fail() {
    local msg="$1"
    echo "$msg" >&2
    if is_sourced; then
        return 1
    fi
    exit 1
}

ensure_pkg() {
    local pkg="$1"
    if rpm -q "$pkg" >/dev/null 2>&1; then
        return 0
    fi
    sudo dnf install -y "$pkg"
}

ensure_pkg curl
ensure_pkg git

default_nvm_dir="$HOME/.nvm"
export NVM_DIR="${NVM_DIR:-$default_nvm_dir}"

install_nvm_init() {
    local target_file="$1"
    [ -f "$target_file" ] || touch "$target_file"

    local begin_marker="# >>> nvm >>>"
    local end_marker="# <<< nvm <<<"

    if grep -Fqx "$begin_marker" "$target_file"; then
        echo "nvm init already present in $target_file, skipping..."
        return 0
    fi

    echo "Adding nvm init to $target_file..."
    {
        echo ""
        echo "$begin_marker"
        echo "export NVM_DIR=\"\$HOME/.nvm\""
        echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\""
        echo "[ -s \"\$NVM_DIR/bash_completion\" ] && . \"\$NVM_DIR/bash_completion\""
        echo "$end_marker"
    } >> "$target_file"
}

if [ -s "$NVM_DIR/nvm.sh" ]; then
    echo "nvm already installed in $NVM_DIR, skipping install..."
else
    echo "Installing nvm via official installer..."
    # Installs to $NVM_DIR
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

# Ensure init for common shells
install_nvm_init "$HOME/.bashrc"
install_nvm_init "$HOME/.zshrc"

# Load nvm into this shell so we can install Node now
# shellcheck source=/dev/null
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
else
    fail "nvm.sh not found at $NVM_DIR/nvm.sh after install."
fi

echo "Installing latest LTS Node.js..."
# Best effort: if LTS install fails due to network, fail the component
nvm install --lts
nvm alias default 'lts/*'

node -v || true
npm -v || true

echo ""
echo "✅ NVM + Node.js (LTS) installation complete!"
echo "Open a new terminal, or run: source ~/.bashrc / source ~/.zshrc"