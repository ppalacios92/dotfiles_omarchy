#!/usr/bin/env bash
set -euo pipefail

BACKGROUND="/home/pxpalacios/Dropbox/01. Brain/10. Ph.D U ANDES/18. OMARCHY/01. Backgrounds/wallhaven-nr1jj0.png"
TARGET="$HOME/.config/omarchy/current/background"

if [ ! -f "$BACKGROUND" ]; then
    echo "ERROR: Background image not found:"
    echo "$BACKGROUND"
    exit 1
fi

mkdir -p "$(dirname "$TARGET")"

echo "Setting background symlink..."
ln -sf "$BACKGROUND" "$TARGET"

echo "Restarting swaybg..."
pkill swaybg 2>/dev/null || true
swaybg -i "$TARGET" -m fill &

echo "Done."
