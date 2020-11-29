#!/bin/bash

# Delete temporary files.

echo "Running autoremove"
sudo apt-get autoremove || exit 1

echo "Running clean"
sudo apt-get clean || exit 1

echo "Moving files to trash bin"
gio trash -f \
~/.adobe/Flash_Player/AssetCache/* \
~/.aliensh_history \
~/.bash_history \
~/.cache/doublecmd/thumbnails/* \
~/.cache/mintinstall/screenshots/* \
~/.cache/thumbnails/*/*.png \
~/.cache/thumbnails/*/*/*.png \
~/.config/xnviewmp/XnView.db \
~/core \
~/.gnuplot_history \
~/kdenlive/thumbs \
~/.kde/share/apps/okular/docdata/* \
~/.kde/share/apps/RecentDocuments/* \
~/.lesshst \
~/.wget-hsts \
~/.nano_history \
~/.python_history \
~/.root_hist \
~/.thumbnails/*/*.png \
~/.thumbnails/*/*/*.png \
~/.vidyo/VidyoDesktop/VidyoDesktop_*.log \
|| exit 1

exit 0
