#!/bin/bash

# Find temporary files.

Dir="$PWD"
[ "$1" ] && Dir="$1"

find "$Dir" \
-name "*~" \
-o -name "*.bak" \
-o -name ".DS_Store" \
-o -name "Thumbs.db"

exit 0
