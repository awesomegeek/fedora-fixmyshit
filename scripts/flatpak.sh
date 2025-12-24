#!/bin/bash

# Flatpak Installation Script for Fedora

set -e  # Exit on error

echo "=========================================="
echo "Installing Flatpak Apps"
echo "=========================================="

# Install Flatpak
if rpm -q flatpak >/dev/null 2>&1; then
  echo "Flatpak package already installed, skipping..."
else
  echo "Installing Flatpak..."
  sudo dnf install -y flatpak
fi

# Add Flathub repository
echo "Adding Flathub repository (if missing)..."
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Apps to install (Flathub IDs)
APPS=(
  "com.google.Chrome"
  "org.videolan.VLC"
  "com.usebruno.Bruno"
  "org.telegram.desktop"
  # "com.slack.Slack"
)

echo ""
echo "Installing Flatpak apps..."

for app in "${APPS[@]}"; do
  if flatpak info "$app" >/dev/null 2>&1; then
    echo "- $app already installed, skipping"
  else
    echo "- Installing $app"
    sudo flatpak install -y flathub "$app"
  fi
done

echo ""
echo "✅ Flatpak installation complete!"
