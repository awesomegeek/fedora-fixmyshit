#!/bin/bash

# Utility CLI tools installation script for Fedora 43
# Installs: Task (taskfile.dev), ripgrep (rg), silver searcher (ag), bat, lsd, yazi, btop, cowsay, sl, thefuck, zellij, lazygit

set -e  # Exit on error

echo "=========================================="
echo "Installing Utility CLI Tools"
echo "=========================================="

# Map: rpm package name -> expected command name (for quick verification output)
# Notes (Fedora):
# - Taskfile.dev: official repo installs package `task`, command `task`
# - The Silver Searcher: package is the_silver_searcher, command is ag
PKGS=(
    "task:task"
    "ripgrep:rg"
    "the_silver_searcher:ag"
    "bat:bat"
    "lsd:lsd"
    "btop:btop"
    "cowsay:cowsay"
    "sl:sl"
)

# Task is installed from the official Task repository (Cloudsmith).
# This keeps `task` up-to-date and ensures the binary name is `task`.
if ! command -v task >/dev/null 2>&1; then
    echo "Setting up Task (taskfile.dev) repository..."
    # Ensure curl is available for the repo bootstrap script
    if command -v curl >/dev/null 2>&1; then
        :
    else
        sudo dnf install -y curl
    fi

    curl -1sLf 'https://dl.cloudsmith.io/public/task/task/setup.rpm.sh' | sudo -E bash
    sudo dnf install -y task
fi

# Some tools may not exist as a stable Fedora RPM on all systems.
# We'll attempt via dnf first, then fall back to python pip (user install) if needed.
EXTRA_TOOLS=(
    "yazi"
    "thefuck"
    "zellij"
    "lazygit"
)

missing_pkgs=()
for entry in "${PKGS[@]}"; do
    IFS=':' read -r pkg cmd <<< "$entry"
    if rpm -q "$pkg" >/dev/null 2>&1; then
        :
    else
        missing_pkgs+=("$pkg")
    fi

done

if [ ${#missing_pkgs[@]} -eq 0 ]; then
    echo "All utility packages already installed, skipping..."
else
    echo "Installing packages: ${missing_pkgs[*]}"

    # Install packages individually so one missing package doesn't block all others.
    failed=()
    set +e
    for pkg in "${missing_pkgs[@]}"; do
        if ! sudo dnf install -y "$pkg"; then
            echo "⚠️  Failed to install package: $pkg"
            failed+=("$pkg")
        fi
    done
    set -e

    if [ ${#failed[@]} -ne 0 ]; then
        echo ""
        echo "Some packages failed to install: ${failed[*]}"
        echo "You may need to enable additional repos or install them manually."
        # Non-zero so the wizard can report failure for this component
        return 1
    fi
fi

# Install extra tools
for tool in "${EXTRA_TOOLS[@]}"; do
    case "$tool" in
        yazi)
            if command -v yazi >/dev/null 2>&1; then
                echo "yazi already installed, skipping..."
                continue
            fi

            echo "Installing yazi (COPR: lihaohong/yazi)..."
            # Ensure COPR support
            if rpm -q dnf-plugins-core >/dev/null 2>&1; then
                :
            else
                sudo dnf install -y dnf-plugins-core
            fi

            sudo dnf -y copr enable lihaohong/yazi
            sudo dnf install -y yazi --setopt=install_weak_deps=False
            ;;
        thefuck)
            if command -v thefuck >/dev/null 2>&1; then
                echo "thefuck already installed, skipping..."
                continue
            fi

            echo "Installing thefuck..."
            if sudo dnf install -y thefuck >/dev/null 2>&1; then
                :
            else
                echo "dnf package 'thefuck' not available; falling back to pip user install..."
                sudo dnf install -y python3 python3-pip
                python3 -m pip install --user --upgrade thefuck
            fi
            ;;
        zellij)
            if command -v zellij >/dev/null 2>&1; then
                echo "zellij already installed, skipping binary download..."
            else
                echo "Installing zellij (binary from GitHub)..."
                # Ensure curl is available
                if ! command -v curl >/dev/null 2>&1; then
                    sudo dnf install -y curl
                fi
                
                # Get latest version and download
                ZELLIJ_VERSION=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
                curl -L "https://github.com/zellij-org/zellij/releases/download/${ZELLIJ_VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz" -o zellij.tar.gz
                tar -xvf zellij.tar.gz
                chmod +x zellij
                mkdir -p "$HOME/.local/bin"
                mv zellij "$HOME/.local/bin/zellij"
                rm zellij.tar.gz
            fi

            # Configuration
            if [ -d "dotfiles/zellij" ]; then
                echo "Configuring zellij dotfiles..."
                ZELLIJ_CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zellij"
                mkdir -p "$ZELLIJ_CONF_DIR"
                cp -r dotfiles/zellij/* "$ZELLIJ_CONF_DIR/"
            fi
            ;;
        lazygit)
            if command -v lazygit >/dev/null 2>&1; then
                echo "lazygit already installed, skipping..."
                continue
            fi

            echo "Installing lazygit (COPR: dejan/lazygit)..."
            # Ensure COPR support
            if rpm -q dnf-plugins-core >/dev/null 2>&1; then
                :
            else
                sudo dnf install -y dnf-plugins-core
            fi

            sudo dnf -y copr enable dejan/lazygit
            sudo dnf install -y lazygit
            ;;
    esac
done

# Quick verification output
echo ""
echo "Installed commands (best effort check):"
for entry in "${PKGS[@]}"; do
    IFS=':' read -r _pkg cmd <<< "$entry"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  ✓ $cmd"
    else
        echo "  → $cmd (not found in PATH)"
    fi
done

for tool in "${EXTRA_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "  ✓ $tool"
    else
        echo "  → $tool (not found in PATH)"
    fi
done

echo ""
echo "✅ Utility tools installation complete!"