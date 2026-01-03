#!/bin/bash

# Conky installation + dashboard configuration for Fedora (GNOME)

set -e  # Exit on error

echo "=========================================="
echo "Installing Conky + Configuring Dashboard"
echo "=========================================="

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

ensure_pkg conky
ensure_pkg iproute
ensure_pkg curl
ensure_pkg lm_sensors

if ! command -v conky >/dev/null 2>&1; then
	fail "conky command not found after installation."
fi

CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/conky"
AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"

TEMPLATE_SRC="dotfiles/conky/conky.conf"
START_SRC="dotfiles/conky/conky-start.sh"

mkdir -p "$CONF_DIR"
mkdir -p "$AUTOSTART_DIR"

if [ ! -f "$TEMPLATE_SRC" ]; then
	fail "Missing $TEMPLATE_SRC (expected from this repo)."
fi

if [ ! -f "$START_SRC" ]; then
	fail "Missing $START_SRC (expected from this repo)."
fi

echo "Syncing Conky config into: $CONF_DIR"
cp -f "$TEMPLATE_SRC" "$CONF_DIR/conky.conf.template"
cp -f "$START_SRC" "$CONF_DIR/conky-start.sh"
chmod +x "$CONF_DIR/conky-start.sh"

AUTOSTART_FILE="$AUTOSTART_DIR/conky.desktop"
echo "Syncing GNOME autostart: $AUTOSTART_FILE"
cat > "$AUTOSTART_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=Conky Dashboard
Comment=System monitor dashboard
Exec=$CONF_DIR/conky-start.sh
OnlyShowIn=GNOME;
X-GNOME-Autostart-enabled=true
NoDisplay=false
Terminal=false
EOF

echo ""
echo "✅ Conky installation + dashboard configuration complete!"
echo ""
echo "Run now (without logging out):"
echo "  $CONF_DIR/conky-start.sh"
echo ""
echo "Disable autostart later by removing:"
echo "  $AUTOSTART_FILE"

