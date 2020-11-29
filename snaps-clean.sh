#!/bin/bash

# https://maslosoft.com/kb/how-to-clean-old-snaps/
# Removes old revisions of snaps
# CLOSE ALL SNAPS BEFORE RUNNING THIS
set -eu

snap list --all | awk '/vypnuto/{print $1, $3}' |
    while read snapname revision; do
        sudo snap remove "$snapname" --revision="$revision"
    done

exit 0
