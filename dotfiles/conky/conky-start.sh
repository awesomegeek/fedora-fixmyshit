#!/bin/bash

set -e

CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/conky"
TEMPLATE_SRC="$CONF_DIR/conky.conf.template"
OUT_CONF="$CONF_DIR/conky.conf"

mkdir -p "$CONF_DIR"

# Give GNOME a moment to finish session startup
sleep 3

# Best-effort: avoid duplicates if autostart runs more than once
pkill -u "$USER" -x conky >/dev/null 2>&1 || true

# Detect the default route interface (works for both ethernet/wifi)
iface=""
if command -v ip >/dev/null 2>&1; then
  iface="$(ip route get 1.1.1.1 2>/dev/null | awk '{for (i=1;i<=NF;i++) if ($i=="dev") {print $(i+1); exit}}')"
fi

# Fallbacks if no default route is available yet
if [ -z "$iface" ]; then
  for candidate in enp0s0 eth0 wlp2s0 wlan0; do
    if [ -d "/sys/class/net/$candidate" ]; then
      iface="$candidate"
      break
    fi
  done
fi

# If we still have nothing, keep the placeholder but avoid hard failure.
if [ -z "$iface" ]; then
  iface="lo"
fi

if [ ! -f "$TEMPLATE_SRC" ]; then
  echo "Conky template not found: $TEMPLATE_SRC" >&2
  exit 1
fi

# Render config with detected iface
sed "s/__IFACE__/$iface/g" "$TEMPLATE_SRC" > "$OUT_CONF"

exec conky -c "$OUT_CONF"