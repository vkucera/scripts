#!/bin/bash

# Delete temporary files.

# Set bash strict mode.
set -euo pipefail

echo "Running autoremove"
sudo apt autoremove

echo "Running clean"
sudo apt clean

echo "Moving files to trash bin"
gio trash -f \
"$HOME"/.aliensh_history \
"$HOME"/.bash_history \
"$HOME"/.cache/doublecmd/thumbnails/* \
"$HOME"/.cache/mintinstall/screenshots/* \
"$HOME"/.cache/thumbnails/*/*.png \
"$HOME"/.cache/thumbnails/*/*/*.png \
"$HOME"/.config/session/* \
"$HOME"/.config/xnviewmp/*log* \
"$HOME"/.config/xnviewmp/XnView.db \
"$HOME"/.lesshst \
"$HOME"/.local/share/Hardcoded\ Software/dupeGuru/cached_pictures.db \
"$HOME"/.local/share/Hardcoded\ Software/dupeGuru/debug.log \
"$HOME"/.local/share/Hardcoded\ Software/dupeGuru/hash_cache.db \
"$HOME"/.local/share/Hardcoded\ Software/dupeGuru/last_directories.xml \
"$HOME"/.local/share/okular/docdata/* \
"$HOME"/.local/share/RecentDocuments/* \
"$HOME"/.nano_history \
"$HOME"/.python_history \
"$HOME"/.root_hist \
"$HOME"/.wget-hsts \
"$HOME"/core \
exit

# Obsolete paths

# ~/.adobe/Flash_Player/AssetCache/* \
# ~/.gnuplot_history \
# ~/.thumbnails/*/*.png \
# ~/.thumbnails/*/*/*.png \
# ~/.vidyo/VidyoDesktop/VidyoDesktop_*.log \
# ~/kdenlive/thumbs \
