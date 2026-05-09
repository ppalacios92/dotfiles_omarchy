#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATE_TAG="$(date +%Y%m%d_%H%M%S)"

echo "Repo: $REPO_DIR"

backup_file() {
    local file="$1"

    if [ -f "$file" ]; then
        cp -a "$file" "$file.backup.$DATE_TAG"
        echo "Backup saved: $file.backup.$DATE_TAG"
    fi
}

backup_dir() {
    local dir="$1"

    if [ -d "$dir" ]; then
        cp -a "$dir" "$dir.backup.$DATE_TAG"
        echo "Backup saved: $dir.backup.$DATE_TAG"
    fi
}

install_dir() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [ -d "$src" ]; then
        echo "Installing $name..."
        backup_dir "$dst"
        mkdir -p "$dst"
        rsync -av "$src/" "$dst/"
    else
        echo "Skipping $name: source not found: $src"
    fi
}

install_file() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [ -f "$src" ]; then
        echo "Installing $name..."
        mkdir -p "$(dirname "$dst")"
        backup_file "$dst"
        cp -v "$src" "$dst"
    else
        echo "Skipping $name: source not found: $src"
    fi
}

install_dir "$REPO_DIR/hypr" "$HOME/.config/hypr" "Hyprland config"
install_dir "$REPO_DIR/waybar" "$HOME/.config/waybar" "Waybar config"

install_file "$REPO_DIR/starship/starship.toml" "$HOME/.config/starship.toml" "Starship config"
install_file "$REPO_DIR/mimeapps/mimeapps.list" "$HOME/.config/mimeapps.list" "default apps config"

if [ -x "$REPO_DIR/scripts/set-background.sh" ]; then
    echo "Applying background..."
    "$REPO_DIR/scripts/set-background.sh" || true
fi

echo "Reloading Hyprland..."
if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload || true
fi

echo "Restarting Waybar..."
if command -v waybar >/dev/null 2>&1; then
    pkill waybar 2>/dev/null || true
    waybar >/tmp/waybar.log 2>&1 &
fi

echo "Done."
