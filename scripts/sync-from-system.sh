#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

HYPR_SRC="$HOME/.config/hypr"
HYPR_DST="$REPO_DIR/hypr"

echo "Repo: $REPO_DIR"

if [ ! -d "$HYPR_SRC" ]; then
    echo "ERROR: System Hypr config not found: $HYPR_SRC"
    exit 1
fi

echo "Syncing Hypr config from system into repo..."
mkdir -p "$HYPR_DST"
rsync -av --delete "$HYPR_SRC/" "$HYPR_DST/"

echo "Done."
