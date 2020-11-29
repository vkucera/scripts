#!/bin/bash

# Skript rozbali archiv, ktery byl zabalen pomoci tar a pak zkomprimovan pomoci 7z.

echo "Zdroj: $1"
7zr x -so $1 | tar xf -
exit 0

