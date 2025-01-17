#!/bin/bash

# https://help.ubuntu.com/community/BackupYourSystem/TAR

target="backup.tar.gz"

sudo tar -cvpzf "$target" --one-file-system \
--exclude="$target" \
--exclude=/dev \
--exclude=/home/*/.cache \
--exclude=/home/*/.gvfs \
--exclude=/home/*/.local/share/Trash \
--exclude=/media \
--exclude=/mnt \
--exclude=/proc \
--exclude=/run \
--exclude=/sys \
--exclude=/tmp \
--exclude=/usr/src/linux-headers* \
--exclude=/var/cache/apt/archives \
--exclude=/var/log \
/
