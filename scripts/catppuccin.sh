#!/bin/bash

# Catppuccin theme installation for GNOME Terminal (Fedora 43)
# Installs Catppuccin profiles using gsettings.

set -e

echo "=========================================="
echo "Installing Catppuccin (GNOME Terminal)"
echo "=========================================="

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
	echo "This script should not be run as root (it configures your user dconf)."
	return 1
fi

if ! command -v gsettings >/dev/null 2>&1; then
	echo "gsettings not found; installing glib2..."
	sudo dnf install -y glib2
fi

# Ensure GNOME Terminal schemas are available
if ! gsettings list-schemas 2>/dev/null | grep -q '^org\.gnome\.Terminal\.'; then
	echo "GNOME Terminal gsettings schemas not found; installing gnome-terminal..."
	sudo dnf install -y gnome-terminal
fi

if ! gsettings list-schemas 2>/dev/null | grep -q '^org\.gnome\.Terminal\.'; then
	echo "GNOME Terminal schemas still not available; cannot configure theme."
	return 1
fi

if ! command -v python3 >/dev/null 2>&1; then
	echo "python3 not found; installing..."
	sudo dnf install -y python3
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
python3 "$script_dir/catppuccin_gnome_terminal.py"

echo ""
echo "✅ Catppuccin profiles installed in GNOME Terminal."
echo "Open GNOME Terminal → Preferences → Profiles to select one."
