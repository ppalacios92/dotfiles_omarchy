#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USER_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
DATE_TAG="$(date +%Y%m%d_%H%M%S)"

usage() {
    cat <<'EOF'
Usage: scripts/install.sh [--omarchy-3|--omarchy-4]

Without an option, the installed Omarchy major version is detected.
Omarchy 4 installs the Lua/Omarchy Shell configuration.
Omarchy 3 installs the preserved .conf/Waybar configuration.
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
            echo "ERROR: Unsupported or unknown Omarchy version: ${version:-<empty>}" >&2
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

backup_file() {
    local file="$1"

    if [[ -e "$file" || -L "$file" ]]; then
        cp -a "$file" "$file.backup.$DATE_TAG"
        echo "Backup saved: $file.backup.$DATE_TAG"
    fi
}

install_file() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [[ ! -f "$src" ]]; then
        echo "ERROR: Missing $name source: $src" >&2
        exit 1
    fi

    echo "Installing $name..."
    mkdir -p "$(dirname "$dst")"
    backup_file "$dst"
    cp -v "$src" "$dst"
}

install_hyprland_4() {
    local name
    for name in hyprland monitors input bindings looknfeel autostart; do
        install_file "$REPO_DIR/hypr/$name.lua" "$USER_CONFIG_DIR/hypr/$name.lua" "Hyprland $name.lua"
    done

    install_file "$REPO_DIR/omarchy/shell.json" "$USER_CONFIG_DIR/omarchy/shell.json" "Omarchy Shell config"
    install_file "$REPO_DIR/omarchy/plugins/pxpalacios.workspaces/Workspaces.qml" "$USER_CONFIG_DIR/omarchy/plugins/pxpalacios.workspaces/Workspaces.qml" "six-workspace widget"
    install_file "$REPO_DIR/omarchy/plugins/pxpalacios.workspaces/manifest.json" "$USER_CONFIG_DIR/omarchy/plugins/pxpalacios.workspaces/manifest.json" "six-workspace widget manifest"
}

install_hyprland_3() {
    local name
    for name in hyprland monitors input bindings looknfeel autostart; do
        install_file "$REPO_DIR/hypr/$name.conf" "$USER_CONFIG_DIR/hypr/$name.conf" "legacy Hyprland $name.conf"
    done

    install_file "$REPO_DIR/waybar/config.jsonc" "$USER_CONFIG_DIR/waybar/config.jsonc" "legacy Waybar config"
    install_file "$REPO_DIR/waybar/style.css" "$USER_CONFIG_DIR/waybar/style.css" "legacy Waybar style"
}

echo "Repo: $REPO_DIR"
echo "Target: Omarchy $OMARCHY_MAJOR"

if [[ "$OMARCHY_MAJOR" == 4 ]]; then
    install_hyprland_4
else
    install_hyprland_3
fi

install_file "$REPO_DIR/starship/starship.toml" "$USER_CONFIG_DIR/starship.toml" "Starship config"
install_file "$REPO_DIR/mimeapps/mimeapps.list" "$USER_CONFIG_DIR/mimeapps.list" "default apps config"

if [[ -x "$REPO_DIR/scripts/set-background.sh" ]]; then
    "$REPO_DIR/scripts/set-background.sh" "--omarchy-$OMARCHY_MAJOR"
fi

if [[ -x "$REPO_DIR/scripts/set-icon-theme.sh" ]]; then
    "$REPO_DIR/scripts/set-icon-theme.sh"
fi

if [[ "$OMARCHY_MAJOR" == 4 ]]; then
    if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        echo "Reloading and validating Hyprland..."
        hyprctl reload
        config_errors="$(hyprctl configerrors)"
        if [[ -n "$config_errors" ]]; then
            echo "ERROR: Hyprland reported configuration errors:" >&2
            printf '%s\n' "$config_errors" >&2
            exit 1
        fi
    else
        echo "Hyprland session not detected; configuration will apply on next login."
    fi

    if command -v omarchy-shell >/dev/null 2>&1; then
        omarchy-shell shell rescanPlugins
    fi
else
    if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        hyprctl reload
    fi

    if command -v waybar >/dev/null 2>&1; then
        echo "Restarting legacy Waybar..."
        pkill waybar 2>/dev/null || true
        waybar >/tmp/waybar.log 2>&1 &
    fi
fi

echo "Done. Omarchy $OMARCHY_MAJOR configuration installed."
