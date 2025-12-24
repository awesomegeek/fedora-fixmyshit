#!/bin/bash

# SSH keys import script
# Copies SSH config/keys from this repo's dotfiles/.ssh into ~/.ssh with safe permissions.

set -e  # Exit on error

echo "=========================================="
echo "Importing SSH keys"
echo "=========================================="

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

src_dir="$repo_root/dotfiles/.ssh"
dest_dir="$HOME/.ssh"

if [ ! -d "$src_dir" ]; then
    echo "Source directory not found: $src_dir"
    echo "Nothing to import."
    return 0
fi

mkdir -p "$dest_dir"
chmod 700 "$dest_dir"

backup_root="$dest_dir/backup.$(date +%Y%m%d%H%M%S)"
backed_up_any=0

copy_one() {
    local src_file="$1"
    local base
    base="$(basename "$src_file")"
    local dest_file="$dest_dir/$base"

    # Decide permissions
    local mode="600"
    case "$base" in
        *.pub) mode="644";;
        known_hosts) mode="644";;
        config) mode="600";;
        id_*|*_rsa|*_dsa|*_ecdsa|*_ed25519) mode="600";;
    esac

    if [ -f "$dest_file" ]; then
        if cmp -s "$src_file" "$dest_file"; then
            echo "Unchanged: $base"
            return 0
        fi

        if [ "$backed_up_any" -eq 0 ]; then
            mkdir -p "$backup_root"
            backed_up_any=1
        fi
        echo "Backing up existing $base to $backup_root/"
        cp -f "$dest_file" "$backup_root/$base"
    fi

    install -m "$mode" "$src_file" "$dest_file"
    echo "Imported: $base (mode $mode)"
}

shopt -s nullglob
files=("$src_dir"/*)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
    echo "No files found in $src_dir"
    return 0
fi

for f in "${files[@]}"; do
    if [ -f "$f" ]; then
        copy_one "$f"
    fi
done

echo ""
echo "✅ SSH import complete!"
if [ "$backed_up_any" -eq 1 ]; then
    echo "Backups saved under: $backup_root"
fi