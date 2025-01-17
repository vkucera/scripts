#!/bin/bash

# Delete temporary files.

echo "Running autoremove"
sudo apt-get autoremove || exit 1

echo "Running clean"
sudo apt-get clean || exit 1

echo "Moving files to trash bin"
gio trash -f \
~/.aliensh_history \
~/.bash_history \
~/.cache/doublecmd/thumbnails/* \
~/.cache/mintinstall/screenshots/* \
~/.cache/thumbnails/*/*.png \
~/.cache/thumbnails/*/*/*.png \
~/.config/xnviewmp/XnView.db \
~/.lesshst \
~/.local/share/okular/docdata/* \
~/.local/share/RecentDocuments/* \
~/.nano_history \
~/.python_history \
~/.root_hist \
~/.wget-hsts \
~/core \
|| exit 1

# Obsolete paths

# ~/.adobe/Flash_Player/AssetCache/* \
# ~/.gnuplot_history \
# ~/.thumbnails/*/*.png \
# ~/.thumbnails/*/*/*.png \
# ~/.vidyo/VidyoDesktop/VidyoDesktop_*.log \
# ~/kdenlive/thumbs \
