#!/bin/bash

# Nerd Fonts Installation Script for Fedora 43
# Installs: JetBrainsMono Nerd Font, Victor Mono, FiraCode Nerd Font

set -e  # Exit on error

echo "=========================================="
echo "Installing Nerd Fonts"
echo "=========================================="

# Fonts to install (easy to customize)
# Format: "Label|ZipAsset|InstallDirName"
# ZipAsset must match the Nerd Fonts release asset name.
NERD_FONTS=(
    "JetBrainsMono Nerd Font|JetBrainsMono.zip|JetBrainsMono"
    "Victor Mono Nerd Font|VictorMono.zip|VictorMono"
    "FiraCode Nerd Font|FiraCode.zip|FiraCode"
)

# Ensure required tools exist
required_pkgs=(
    curl
    unzip
    fontconfig
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

fonts_root="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
nerd_root="$fonts_root/NerdFonts"
mkdir -p "$nerd_root"

install_any=0

install_nerd_font_zip() {
    local font_label="$1"     # Human-friendly name
    local zip_name="$2"       # Nerd Fonts release asset name, e.g. JetBrainsMono.zip
    local dest_dir="$3"       # Destination folder

    if [ -d "$dest_dir" ] && find "$dest_dir" -maxdepth 1 -type f \( -iname '*.ttf' -o -iname '*.otf' \) | grep -q .; then
        echo "$font_label already installed, skipping..."
        return 0
    fi

    mkdir -p "$dest_dir"

    local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${zip_name}"
    echo "Downloading $font_label from: $url"

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    local zip_path="$tmp_dir/$zip_name"

    # Download
    curl -fsSL -o "$zip_path" "$url"

    # Extract only font files
    unzip -q "$zip_path" -d "$tmp_dir/extract"

    local copied=0
    shopt -s nullglob
    for f in "$tmp_dir"/extract/*.ttf "$tmp_dir"/extract/*.otf; do
        cp -f "$f" "$dest_dir/"
        copied=1
    done
    shopt -u nullglob

    rm -rf "$tmp_dir"

    if [ "$copied" -eq 1 ]; then
        echo "Installed $font_label to: $dest_dir"
        install_any=1
    else
        echo "No font files found in archive for $font_label."
        return 1
    fi
}

for entry in "${NERD_FONTS[@]}"; do
    IFS='|' read -r font_label zip_name dir_name <<< "$entry"
    install_nerd_font_zip "$font_label" "$zip_name" "$nerd_root/$dir_name"
done

if [ "$install_any" -eq 1 ]; then
    echo "Refreshing font cache..."
    fc-cache -f "$fonts_root" >/dev/null 2>&1 || fc-cache -f >/dev/null 2>&1
fi

echo ""
echo "✅ Nerd Fonts installation complete!"
echo ""
echo "If apps don’t see the fonts immediately, log out/in or restart the app."