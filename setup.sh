#!/bin/bash

# Main Setup Script for Fedora 43
# Run this script to set up your system automatically

set -e  # Exit on error

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SETUP_COMPONENTS=()

# Flatpak apps installed by this rig
FLATPAK_APPS=(
    "org.telegram.desktop"
    "org.videolan.VLC"
    "com.slack.Slack"
    "com.usebruno.Bruno"
)

# Functions
show_header() {
    clear
    echo -e "${CYAN}=========================================="
    echo -e "   fedora-fixmyshit - Fedora 43 Setup Wizard"
    echo -e "==========================================${NC}"
    echo ""
}

show_welcome() {
    show_header
    echo -e "${GREEN}Welcome to fedora-fixmyshit Setup Wizard!${NC}"
    echo ""
    echo "This wizard will help you set up your Fedora 43 system"
    echo "with custom configurations and tools."
    echo ""
    echo "You can choose:"
    echo "  • Full automatic installation"
    echo "  • Custom installation (select components)"
    echo "  • View what will be installed"
    echo ""
    read -p "Press Enter to continue..."
}

show_menu() {
    show_header
    echo -e "${BLUE}Setup Mode Selection${NC}"
    echo ""
    echo "1) Quick Setup (Install everything)"
    echo "2) Custom Setup (Choose components)"
    echo "3) View Components"
    echo "4) Exit"
    echo ""
    read -p "Select an option [1-4]: " choice
    
    case $choice in
        1) setup_mode="full" ;;
        2) setup_mode="custom" ;;
        3) view_components; show_menu ;;
        4) exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1; show_menu ;;
    esac
}

view_components() {
    show_header
    echo -e "${BLUE}Available Components${NC}"
    echo ""
    echo -e "${GREEN}✓${NC} Git Configuration"
    echo "  - Installs Git"
    echo "  - Sets git user.name/user.email"
    echo "  - Sets git core.editor to vim"
    echo ""

    echo -e "${GREEN}✓${NC} SSH Keys (Import)"
    echo "  - Imports SSH config/keys from repo dotfiles/.ssh"
    echo "  - Copies into ~/.ssh with safe permissions"
    echo ""

    echo -e "${GREEN}✓${NC} Zsh Shell"
    echo "  - Installs Zsh"
    echo "  - Installs Starship prompt"
    echo "  - Sets Zsh as default shell"
    echo ""
    echo -e "${GREEN}✓${NC} Neovim + LazyVim"
    echo "  - Installs Neovim"
    echo "  - Installs LazyVim starter config"
    echo "  - Installs common dependencies (ripgrep, fd, build tools)"
    echo ""
    echo -e "${GREEN}✓${NC} Nerd Fonts"
    echo "  - Installs JetBrainsMono Nerd Font"
    echo "  - Installs Victor Mono Nerd Font"
    echo "  - Installs FiraCode Nerd Font"
    echo ""
    echo -e "${GREEN}✓${NC} Flatpak Apps"
    echo "  - Installs Flatpak and adds Flathub"
    echo "  - Installs: Telegram, VLC, Slack"
    echo ""

    echo -e "${GREEN}✓${NC} Python tooling (uv)"
    echo "  - Installs uv (Astral)"
    echo ""
    echo -e "${GREEN}✓${NC} Node.js (nvm)"
    echo "  - Installs nvm"
    echo "  - Installs latest LTS Node.js"
    echo ""

    echo -e "${GREEN}✓${NC} Rust (rustup)"
    echo "  - Installs rustup + stable toolchain"
    echo ""

    echo -e "${GREEN}✓${NC} Go (Golang)"
    echo "  - Installs Go compiler/tooling"
    echo ""

    echo -e "${GREEN}✓${NC} Docker + LazyDocker"
    echo "  - Installs Docker Engine + Docker Compose plugin"
    echo "  - Installs lazydocker"
    echo ""

    echo -e "${GREEN}✓${NC} Utility CLI Tools"
    echo "  - Installs Task (taskfile.dev), rg, ag, bat, lsd, yazi, btop, cowsay, sl, zellij, lazygit"
    echo "  - Configures Zellij with dotfiles"
    echo ""

    echo -e "${GREEN}✓${NC} AI Tooling"
    echo "  - Installs OpenCode (opencode.ai)"
    echo ""

    echo -e "${YELLOW}Coming Soon:${NC}"
    echo "  • System Updates"
    echo "  • Development Tools"
    echo "  • Desktop Applications"
    echo "  • Dotfiles Configuration"
    echo ""
    read -p "Press Enter to return to menu..."
}

select_components() {
    show_header
    echo -e "${BLUE}Component Selection${NC}"
    echo ""
    echo "Select components to install (press Enter when done):"
    echo ""
    
    # Define available components (fixed order; associative arrays are unordered)
    declare -A components=(
        ["git"]="Git configuration (name/email/editor)"
        ["ssh"]="SSH keys import (from dotfiles/.ssh)"
        ["zsh"]="Zsh Shell (Starship prompt)"
        ["neovim"]="Neovim + LazyVim"
        ["flatpak"]="Flatpak Apps (Telegram, VLC, Slack)"
        ["uv"]="Python tooling: uv (Astral)"
        ["nvm"]="Node.js via nvm (latest LTS)"
        ["rust"]="Rust via rustup (stable)"
        ["golang"]="Go (Golang)"
        ["docker"]="Docker + LazyDocker"
        ["nerdfonts"]="Nerd Fonts (JetBrainsMono/VictorMono/FiraCode)"
        ["utils"]="Utility CLI tools (task/rg/ag/bat/lsd/yazi/cowsay/sl/lazygit)"
        ["ai"]="AI Tooling (OpenCode)"
    )

    component_order=(git ssh zsh neovim flatpak uv nvm rust golang docker nerdfonts utils ai)

    for key in "${component_order[@]}"; do
        while true; do
            read -p "Install ${components[$key]}? [Y/n]: " answer
            case ${answer:-y} in
                [Yy]* ) SETUP_COMPONENTS+=("$key"); break;;
                [Nn]* ) break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    done
    
    # Show summary
    echo ""
    if [ ${#SETUP_COMPONENTS[@]} -eq 0 ]; then
        echo -e "${YELLOW}No components selected. Exiting.${NC}"
        exit 0
    fi
    
    echo -e "${GREEN}Selected components:${NC}"
    for component in "${SETUP_COMPONENTS[@]}"; do
        echo "  • ${components[$component]}"
    done
    echo ""
    read -p "Proceed with installation? [Y/n]: " confirm
    case ${confirm:-y} in
        [Yy]* ) ;;
        * ) exit 0;;
    esac
}

check_system() {
    show_header
    echo -e "${BLUE}System Check${NC}"
    echo ""
    
    # Check if running on Fedora
    if [ ! -f /etc/fedora-release ]; then
        echo -e "${YELLOW}⚠️  Warning: This script is designed for Fedora 43${NC}"
        read -p "Continue anyway? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        echo -e "${GREEN}✓${NC} Running on Fedora"
    fi
    
    # Make all scripts executable
    chmod +x scripts/*.sh 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Scripts are executable"
    echo ""
}

run_installation() {
    show_header
    echo -e "${BLUE}Installation Progress${NC}"
    echo ""

    local index=1
    local total=${#SETUP_COMPONENTS[@]}

    for component in "${SETUP_COMPONENTS[@]}"; do
        case $component in
            zsh)
                echo -e "${CYAN}[${index}/${total}] Installing Zsh Shell...${NC}"
                if source scripts/zsh.sh; then
                    echo -e "${GREEN}✓ Zsh installation completed${NC}"
                else
                    echo -e "${RED}✗ Zsh installation failed${NC}"
                fi
                echo ""
                ;;
            neovim)
                echo -e "${CYAN}[${index}/${total}] Installing Neovim + LazyVim...${NC}"
                if source scripts/neovim_lazyvim.sh; then
                    echo -e "${GREEN}✓ Neovim + LazyVim installation completed${NC}"
                else
                    echo -e "${RED}✗ Neovim + LazyVim installation failed${NC}"
                fi
                echo ""
                ;;
            utils)
                echo -e "${CYAN}[${index}/${total}] Installing utility CLI tools...${NC}"
                if source scripts/utils.sh; then
                    echo -e "${GREEN}✓ Utility tools installation completed${NC}"
                else
                    echo -e "${RED}✗ Utility tools installation failed${NC}"
                fi
                echo ""
                ;;
            uv)
                echo -e "${CYAN}[${index}/${total}] Installing uv...${NC}"
                if source scripts/uv.sh; then
                    echo -e "${GREEN}✓ uv installation completed${NC}"
                else
                    echo -e "${RED}✗ uv installation failed${NC}"
                fi
                echo ""
                ;;
            nvm)
                echo -e "${CYAN}[${index}/${total}] Installing Node.js (nvm)...${NC}"
                if source scripts/nvm.sh; then
                    echo -e "${GREEN}✓ Node.js (nvm) installation completed${NC}"
                else
                    echo -e "${RED}✗ Node.js (nvm) installation failed${NC}"
                fi
                echo ""
                ;;
            rust)
                echo -e "${CYAN}[${index}/${total}] Installing Rust (rustup)...${NC}"
                if source scripts/rust.sh; then
                    echo -e "${GREEN}✓ Rust installation completed${NC}"
                else
                    echo -e "${RED}✗ Rust installation failed${NC}"
                fi
                echo ""
                ;;
            golang)
                echo -e "${CYAN}[${index}/${total}] Installing Go (Golang)...${NC}"
                if source scripts/golang.sh; then
                    echo -e "${GREEN}✓ Go installation completed${NC}"
                else
                    echo -e "${RED}✗ Go installation failed${NC}"
                fi
                echo ""
                ;;
            docker)
                echo -e "${CYAN}[${index}/${total}] Installing Docker + LazyDocker...${NC}"
                if source scripts/docker.sh; then
                    echo -e "${GREEN}✓ Docker + LazyDocker installation completed${NC}"
                else
                    echo -e "${RED}✗ Docker + LazyDocker installation failed${NC}"
                fi
                echo ""
                ;;
            git)
                echo -e "${CYAN}[${index}/${total}] Configuring Git...${NC}"
                if source scripts/git.sh; then
                    echo -e "${GREEN}✓ Git configuration completed${NC}"
                else
                    echo -e "${RED}✗ Git configuration failed${NC}"
                fi
                echo ""
                ;;
            ai)
                echo -e "${CYAN}[${index}/${total}] Installing AI Tooling...${NC}"
                if source scripts/ai.sh; then
                    echo -e "${GREEN}✓ AI Tooling installation completed${NC}"
                else
                    echo -e "${RED}✗ AI Tooling installation failed${NC}"
                fi
                echo ""
                ;;
            ssh)
                echo -e "${CYAN}[${index}/${total}] Importing SSH keys...${NC}"
                if source scripts/ssh.sh; then
                    echo -e "${GREEN}✓ SSH import completed${NC}"
                else
                    echo -e "${RED}✗ SSH import failed${NC}"
                fi
                echo ""
                ;;
            nerdfonts)
                echo -e "${CYAN}[${index}/${total}] Installing Nerd Fonts...${NC}"
                if source scripts/nerdfonts.sh; then
                    echo -e "${GREEN}✓ Nerd Fonts installation completed${NC}"
                else
                    echo -e "${RED}✗ Nerd Fonts installation failed${NC}"
                fi
                echo ""
                ;;
            flatpak)
                echo -e "${CYAN}[${index}/${total}] Installing Flatpak Apps...${NC}"
                if source scripts/flatpak.sh; then
                    echo -e "${GREEN}✓ Flatpak apps installation completed${NC}"
                else
                    echo -e "${RED}✗ Flatpak apps installation failed${NC}"
                fi
                echo ""
                ;;
        esac

        index=$((index + 1))
    done
}

show_completion() {
    show_header
    echo -e "${GREEN}=========================================="
    echo -e "   ✨ Setup Complete!"
    echo -e "==========================================${NC}"
    echo ""
    echo -e "${YELLOW}Important:${NC}"
    echo "⚠️  Please log out and log back in for all changes to take effect."
    echo ""
    echo "Installed components:"
    for component in "${SETUP_COMPONENTS[@]}"; do
        echo "  ✓ $component"
    done
    echo ""
}

is_zsh_installed() {
    command -v zsh >/dev/null 2>&1
}

is_starship_installed() {
    command -v starship >/dev/null 2>&1
}

is_starship_configured_for_zsh() {
    local zshrc="$HOME/.zshrc"
    [ -f "$zshrc" ] && grep -Fqx 'eval "$(starship init zsh)"' "$zshrc"
}

is_default_shell_zsh() {
    local current_shell
    current_shell="$(getent passwd "$USER" | cut -d: -f7)"
    local zsh_path
    zsh_path="$(command -v zsh 2>/dev/null || true)"
    [ -n "$zsh_path" ] && [ "$current_shell" = "$zsh_path" ]
}

is_flatpak_installed() {
    command -v flatpak >/dev/null 2>&1
}

is_neovim_installed() {
    command -v nvim >/dev/null 2>&1
}

is_utils_installed() {
    command -v task >/dev/null 2>&1 \
        && command -v rg >/dev/null 2>&1 \
        && command -v ag >/dev/null 2>&1 \
        && command -v bat >/dev/null 2>&1 \
        && command -v lsd >/dev/null 2>&1 \
        && command -v yazi >/dev/null 2>&1 \
        && command -v btop >/dev/null 2>&1 \
        && command -v cowsay >/dev/null 2>&1 \
        && command -v sl >/dev/null 2>&1 \
        && command -v thefuck >/dev/null 2>&1 \
        && command -v zellij >/dev/null 2>&1 \
        && command -v lazygit >/dev/null 2>&1
}

is_uv_installed() {
    command -v uv >/dev/null 2>&1
}

is_ai_installed() {
    command -v opencode >/dev/null 2>&1
}

is_nvm_node_installed() {
    command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1
}

is_rust_installed() {
    command -v rustc >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1
}

is_golang_installed() {
    command -v go >/dev/null 2>&1
}

is_docker_installed() {
    command -v docker >/dev/null 2>&1
}

is_lazydocker_installed() {
    command -v lazydocker >/dev/null 2>&1
}

is_lazyvim_config_present() {
    local nvim_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    [ -f "$nvim_dir/lua/config/lazy.lua" ] && [ -f "$nvim_dir/lazy-lock.json" ]
}

is_git_installed() {
    command -v git >/dev/null 2>&1
}

nerdfonts_font_installed() {
    local font_dir="$1"
    [ -d "$font_dir" ] && find "$font_dir" -maxdepth 1 -type f \( -iname '*.ttf' -o -iname '*.otf' \) | grep -q .
}

git_global_equals() {
    local key="$1"
    local expected="$2"
    [ "$(git config --global --get "$key" 2>/dev/null || true)" = "$expected" ]
}

ssh_repo_has_keys() {
    [ -d "dotfiles/.ssh" ] && find "dotfiles/.ssh" -maxdepth 1 -type f | grep -q .
}

is_flatpak_app_installed() {
    local app_id="$1"
    flatpak info "$app_id" >/dev/null 2>&1
}

preflight_summary() {
    show_header
    echo -e "${BLUE}Preflight Check${NC}"
    echo ""
    echo "Checking selected components before installing..."
    echo ""

    for component in "${SETUP_COMPONENTS[@]}"; do
        case "$component" in
            zsh)
                if is_zsh_installed && is_starship_installed && is_starship_configured_for_zsh && is_default_shell_zsh; then
                    echo -e "${GREEN}✓${NC} Zsh: already installed/configured"
                else
                    echo -e "${YELLOW}→${NC} Zsh: will install/configure"
                    is_zsh_installed || echo "  - will install package: zsh"
                    is_starship_installed || echo "  - will install: Starship prompt"
                    is_starship_configured_for_zsh || echo "  - will configure: Starship in ~/.zshrc"
                    is_default_shell_zsh || echo "  - will set Zsh as default shell"
                fi
                ;;
            neovim)
                if is_neovim_installed && is_lazyvim_config_present; then
                    echo -e "${GREEN}✓${NC} Neovim + LazyVim: already installed/configured"
                else
                    echo -e "${YELLOW}→${NC} Neovim + LazyVim: will install/configure"
                    is_neovim_installed || echo "  - will install package: neovim"
                    is_lazyvim_config_present || echo "  - will install: LazyVim starter config"
                fi
                ;;
            utils)
                if is_utils_installed; then
                    echo -e "${GREEN}✓${NC} Utilities: already installed"
                else
                    echo -e "${YELLOW}→${NC} Utilities: will install"
                    command -v task >/dev/null 2>&1 || echo "  - will install: task (taskfile.dev)"
                    command -v rg >/dev/null 2>&1 || echo "  - will install: rg (ripgrep)"
                    command -v ag >/dev/null 2>&1 || echo "  - will install: ag (the_silver_searcher)"
                    command -v bat >/dev/null 2>&1 || echo "  - will install: bat"
                    command -v lsd >/dev/null 2>&1 || echo "  - will install: lsd"
                    command -v yazi >/dev/null 2>&1 || echo "  - will install: yazi"
                    command -v btop >/dev/null 2>&1 || echo "  - will install: btop"
                    command -v cowsay >/dev/null 2>&1 || echo "  - will install: cowsay"
                    command -v sl >/dev/null 2>&1 || echo "  - will install: sl"
                    command -v thefuck >/dev/null 2>&1 || echo "  - will install: thefuck"
                fi
                ;;
            uv)
                if is_uv_installed; then
                    echo -e "${GREEN}✓${NC} uv: already installed"
                else
                    echo -e "${YELLOW}→${NC} uv: will install"
                fi
                ;;
            nvm)
                if is_nvm_node_installed; then
                    echo -e "${GREEN}✓${NC} Node.js (nvm): already installed"
                else
                    echo -e "${YELLOW}→${NC} Node.js (nvm): will install"
                fi
                ;;
            rust)
                if is_rust_installed; then
                    echo -e "${GREEN}✓${NC} Rust: already installed"
                else
                    echo -e "${YELLOW}→${NC} Rust: will install"
                fi
                ;;
            golang)
                if is_golang_installed; then
                    echo -e "${GREEN}✓${NC} Go: already installed"
                else
                    echo -e "${YELLOW}→${NC} Go: will install"
                fi
                ;;
            docker)
                if is_docker_installed && is_lazydocker_installed; then
                    echo -e "${GREEN}✓${NC} Docker + LazyDocker: already installed"
                else
                    echo -e "${YELLOW}→${NC} Docker + LazyDocker: will install"
                    is_docker_installed || echo "  - will install: Docker Engine"
                    is_lazydocker_installed || echo "  - will install: lazydocker"
                fi
                ;;
            git)
                if is_git_installed \
                    && git_global_equals user.email "naingtunwin@gmail.com" \
                    && git_global_equals user.name "AwesomeGeek" \
                    && git_global_equals core.editor "vim"; then
                    echo -e "${GREEN}✓${NC} Git: already configured"
                else
                    echo -e "${YELLOW}→${NC} Git: will configure"
                    is_git_installed || echo "  - will install package: git"
                    git_global_equals user.email "naingtunwin@gmail.com" || echo "  - will set: git user.email"
                    git_global_equals user.name "AwesomeGeek" || echo "  - will set: git user.name"
                    git_global_equals core.editor "vim" || echo "  - will set: git core.editor=vim"
                fi
                ;;
            ssh)
                if ssh_repo_has_keys; then
                    echo -e "${YELLOW}→${NC} SSH keys: will import from dotfiles/.ssh"
                    if [ -d "$HOME/.ssh" ] && find "$HOME/.ssh" -maxdepth 1 -type f | grep -q .; then
                        echo "  - existing ~/.ssh detected (will back up any overwritten files)"
                    fi
                else
                    echo -e "${YELLOW}→${NC} SSH keys: dotfiles/.ssh is empty or missing (nothing to import)"
                fi
                ;;
            nerdfonts)
                local fonts_root="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
                local nerd_root="$fonts_root/NerdFonts"
                local jb="$nerd_root/JetBrainsMono"
                local vm="$nerd_root/VictorMono"
                local fc="$nerd_root/FiraCode"

                if nerdfonts_font_installed "$jb" \
                    && nerdfonts_font_installed "$vm" \
                    && nerdfonts_font_installed "$fc"; then
                    echo -e "${GREEN}✓${NC} Nerd Fonts: already installed"
                else
                    echo -e "${YELLOW}→${NC} Nerd Fonts: will install"
                    nerdfonts_font_installed "$jb" || echo "  - will install: JetBrainsMono Nerd Font"
                    nerdfonts_font_installed "$vm" || echo "  - will install: Victor Mono Nerd Font"
                    nerdfonts_font_installed "$fc" || echo "  - will install: FiraCode Nerd Font"
                fi
                ;;
            flatpak)
                if ! is_flatpak_installed; then
                    echo -e "${YELLOW}→${NC} Flatpak: will install Flatpak + apps"
                    echo "  - will install package: flatpak"
                else
                    echo -e "${GREEN}✓${NC} Flatpak: Flatpak is installed"
                fi

                local missing_any=0
                for app_id in "${FLATPAK_APPS[@]}"; do
                    if is_flatpak_installed && is_flatpak_app_installed "$app_id"; then
                        echo -e "  ${GREEN}✓${NC} $app_id"
                    else
                        missing_any=1
                        echo -e "  ${YELLOW}→${NC} $app_id (will install)"
                    fi
                done

                if [ "$missing_any" -eq 0 ] && is_flatpak_installed; then
                    echo -e "  ${GREEN}✓${NC} All Flatpak apps already installed"
                fi
                ;;
        esac
        echo ""
    done

    read -p "Proceed with installation? [Y/n]: " confirm
    case ${confirm:-y} in
        [Yy]* ) ;;
        * ) exit 0;;
    esac
}

# Main execution flow
main() {
    show_welcome
    show_menu
    check_system
    
    if [ "$setup_mode" == "full" ]; then
        # Keep SSH import out of Quick Setup for safety.
        SETUP_COMPONENTS=("git" "zsh" "neovim" "flatpak" "uv" "nvm" "rust" "golang" "docker" "nerdfonts" "utils")
    else
        select_components
    fi

    preflight_summary
    
    run_installation
    show_completion
}

# Run the wizard
main
