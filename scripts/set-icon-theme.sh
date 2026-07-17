#!/usr/bin/env bash
set -euo pipefail

echo "Setting icon theme to Breeze..."
gsettings set org.gnome.desktop.interface icon-theme "breeze"
echo "Done."
