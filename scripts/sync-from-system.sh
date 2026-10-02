#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USER_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

usage() {
    cat <<'EOF'
Usage: scripts/sync-from-system.sh [--omarchy-3|--omarchy-4]

Only files managed by this repository are synchronized. The script never uses
rsync --delete and therefore cannot import backups or delete unrelated config.
EOF
}

detect_major() {
    local version

    if ! command -v omarchy >/dev/null 2>&1; then
        echo "ERROR: Omarchy is not installed; pass --omarchy-3 or --omarchy-4." >&2
        return 1
    fi

    version="$(omarchy version 2>/dev/null || true)"
    case "$version" in
        4.*) printf '4\n' ;;
        3.*) printf '3\n' ;;
        *)
            echo "ERROR: Cannot detect Omarchy major version; pass an explicit option." >&2
            return 1
            ;;
    esac
}

case "${1:-}" in
    "") OMARCHY_MAJOR="$(detect_major)" ;;
    --omarchy-3) OMARCHY_MAJOR=3 ;;
    --omarchy-4) OMARCHY_MAJOR=4 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
esac

sync_file() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [[ ! -f "$src" ]]; then
        echo "ERROR: Missing $name source: $src" >&2
        exit 1
    fi

    echo "Syncing $name..."
    mkdir -p "$(dirname "$dst")"
    cp -v "$src" "$dst"
}

echo "Repo: $REPO_DIR"
echo "Source: active Omarchy $OMARCHY_MAJOR configuration"

if [[ "$OMARCHY_MAJOR" == 4 ]]; then
    for name in hyprland monitors input bindings looknfeel autostart; do
        sync_file "$USER_CONFIG_DIR/hypr/$name.lua" "$REPO_DIR/hypr/$name.lua" "Hyprland $name.lua"
    done
    sync_file "$USER_CONFIG_DIR/omarchy/shell.json" "$REPO_DIR/omarchy/shell.json" "Omarchy Shell config"
    sync_file "$USER_CONFIG_DIR/omarchy/plugins/pxpalacios.workspaces/Workspaces.qml" "$REPO_DIR/omarchy/plugins/pxpalacios.workspaces/Workspaces.qml" "six-workspace widget"
    sync_file "$USER_CONFIG_DIR/omarchy/plugins/pxpalacios.workspaces/manifest.json" "$REPO_DIR/omarchy/plugins/pxpalacios.workspaces/manifest.json" "six-workspace widget manifest"
else
    for name in hyprland monitors input bindings looknfeel autostart; do
        sync_file "$USER_CONFIG_DIR/hypr/$name.conf" "$REPO_DIR/hypr/$name.conf" "legacy Hyprland $name.conf"
    done
    sync_file "$USER_CONFIG_DIR/waybar/config.jsonc" "$REPO_DIR/waybar/config.jsonc" "legacy Waybar config"
    sync_file "$USER_CONFIG_DIR/waybar/style.css" "$REPO_DIR/waybar/style.css" "legacy Waybar style"
fi

sync_file "$USER_CONFIG_DIR/starship.toml" "$REPO_DIR/starship/starship.toml" "Starship config"
sync_file "$USER_CONFIG_DIR/mimeapps.list" "$REPO_DIR/mimeapps/mimeapps.list" "default apps config"

echo "Done. Review git diff before committing."
