#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

HYPR_SRC="$REPO_DIR/hypr"
HYPR_DST="$HOME/.config/hypr"

echo "Repo: $REPO_DIR"

if [ ! -d "$HYPR_SRC" ]; then
    echo "ERROR: Hypr source folder not found: $HYPR_SRC"
    exit 1
fi

if [ -d "$HYPR_DST" ]; then
    BACKUP_DIR="$HOME/.config/hypr.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backing up current Hypr config to:"
    echo "$BACKUP_DIR"
    cp -a "$HYPR_DST" "$BACKUP_DIR"
fi

echo "Installing Hypr config..."
mkdir -p "$HYPR_DST"
rsync -av "$HYPR_SRC/" "$HYPR_DST/"

echo "Reloading Hyprland..."
if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload || true
fi

echo "Done."
