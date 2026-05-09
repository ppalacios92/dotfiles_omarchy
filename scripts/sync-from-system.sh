#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Repo: $REPO_DIR"

sync_dir() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [ -d "$src" ]; then
        echo "Syncing $name..."
        mkdir -p "$dst"
        rsync -av --delete "$src/" "$dst/"
    else
        echo "Skipping $name: source not found: $src"
    fi
}

sync_file() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [ -f "$src" ]; then
        echo "Syncing $name..."
        mkdir -p "$(dirname "$dst")"
        cp -v "$src" "$dst"
    else
        echo "Skipping $name: source not found: $src"
    fi
}

sync_dir "$HOME/.config/hypr" "$REPO_DIR/hypr" "Hyprland config"
sync_dir "$HOME/.config/waybar" "$REPO_DIR/waybar" "Waybar config"

sync_file "$HOME/.config/starship.toml" "$REPO_DIR/starship/starship.toml" "Starship config"
sync_file "$HOME/.config/mimeapps.list" "$REPO_DIR/mimeapps/mimeapps.list" "default apps config"

echo "Done."
