#!/usr/bin/env bash
set -euo pipefail

BACKGROUND="/home/pxpalacios/Dropbox/01. Brain/10. Ph.D U ANDES/18. OMARCHY/01. Backgrounds/wallhaven-nr1jj0.png"

usage() {
    echo "Usage: scripts/set-background.sh [--omarchy-3|--omarchy-4]"
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

if [[ ! -f "$BACKGROUND" ]]; then
    echo "ERROR: Background image not found: $BACKGROUND" >&2
    exit 1
fi

if [[ "$OMARCHY_MAJOR" == 4 ]]; then
    echo "Setting Quattro background through the supported Omarchy command..."
    omarchy theme bg set "$BACKGROUND"
else
    target="$HOME/.config/omarchy/current/background"
    echo "Setting legacy Omarchy 3 background symlink..."
    mkdir -p "$(dirname "$target")"
    ln -nsf "$BACKGROUND" "$target"

    if command -v swaybg >/dev/null 2>&1; then
        pkill swaybg 2>/dev/null || true
        swaybg -i "$target" -m fill &
    fi
fi

echo "Background configured for Omarchy $OMARCHY_MAJOR."
