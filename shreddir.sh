#!/bin/bash

# Shred a directory.

[ -d "$1" ] || { echo "Directory $1 does not exist"; exit 1; }

echo "Shredding directory: $1"
find "$1" -depth -type f -exec "$(dirname "$(realpath "$0")")"/shred.sh {} \; && rm -rf "$1"

exit 0
