#!/bin/bash

# Zsh + Starship Installation and Configuration Script for Fedora 43

set -e  # Exit on error

echo "=========================================="
echo "Installing Zsh Shell"
echo "=========================================="

# Install Zsh
if rpm -q zsh >/dev/null 2>&1; then
    echo "Zsh package already installed, skipping..."
else
    echo "Installing Zsh..."
    sudo dnf install -y zsh
fi

# Install Starship prompt (via COPR)
echo "=========================================="
echo "Installing Starship prompt"
echo "=========================================="

# Ensure dnf copr is available
if rpm -q dnf-plugins-core >/dev/null 2>&1; then
    echo "dnf-plugins-core already installed, skipping..."
else
    echo "Installing dnf-plugins-core (for 'dnf copr')..."
    sudo dnf install -y dnf-plugins-core
fi

# Enable COPR repo (idempotent)
echo "Enabling COPR repo: atim/starship..."
sudo dnf -y copr enable atim/starship

# Install Starship
if rpm -q starship >/dev/null 2>&1; then
    echo "Starship already installed, skipping..."
else
    echo "Installing Starship..."
    sudo dnf install -y starship
fi

# Enable Starship in Zsh
zshrc="$HOME/.zshrc"
if [ ! -f "$zshrc" ]; then
    touch "$zshrc"
fi

ensure_default_editor_exports() {
    local target_file="$1"

    if [ ! -f "$target_file" ]; then
        touch "$target_file"
    fi

    local editor_export_1='export EDITOR=vim'
    local editor_export_2='export VISUAL=vim'

    local need_1=0
    local need_2=0
    grep -Fqx "$editor_export_1" "$target_file" || need_1=1
    grep -Fqx "$editor_export_2" "$target_file" || need_2=1

    if [ "$need_1" -eq 0 ] && [ "$need_2" -eq 0 ]; then
        echo "Default editor already configured in $target_file, skipping..."
    else
        echo "Configuring default editor in $target_file..."
        {
            echo ""
            echo "# Default editor"
            [ "$need_1" -eq 1 ] && echo "$editor_export_1"
            [ "$need_2" -eq 1 ] && echo "$editor_export_2"
        } >> "$target_file"
    fi
}

starship_init='eval "$(starship init zsh)"'
if grep -Fqx "$starship_init" "$zshrc"; then
    echo "Starship already configured in ~/.zshrc, skipping..."
else
    echo "Configuring Starship in ~/.zshrc..."
    {
        echo ""
        echo "# Starship prompt"
        echo "$starship_init"
    } >> "$zshrc"
fi

# Set default editor across common shells
ensure_default_editor_exports "$zshrc"
ensure_default_editor_exports "$HOME/.bashrc"
ensure_default_editor_exports "$HOME/.profile"

# Enable thefuck alias in Zsh (if installed later, the next shell startup will pick it up)
thefuck_init='eval $(thefuck --alias)'
if grep -Fqx "$thefuck_init" "$zshrc"; then
    echo "thefuck already configured in ~/.zshrc, skipping..."
else
    echo "Configuring thefuck in ~/.zshrc..."
    {
        echo ""
        echo "# thefuck"
        echo "$thefuck_init"
    } >> "$zshrc"
fi

# Set Zsh as default shell
echo "Setting Zsh as default shell..."
current_shell="$(getent passwd "$USER" | cut -d: -f7)"
zsh_path="$(command -v zsh)"
if [ "$current_shell" = "$zsh_path" ]; then
    echo "Zsh already set as default shell, skipping..."
else
    sudo chsh -s "$zsh_path" "$USER"
fi

echo ""
echo "✅ Zsh + Starship installation complete!"
echo ""
echo "⚠️  You need to log out and log back in for the shell change to take effect."
echo ""
