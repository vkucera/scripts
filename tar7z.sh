#!/bin/bash

# Skript archivuje vstup pomoci tar a pak ho zkomprimuje pomoci 7z.
# Pouziti: tar7z.sh <nazev_archivu> <seznam_vstupnich_polozek>

archiv="$1.tar.7z"
# smazani prvniho argumentu (nazev archivu)
shift
# zbyvajici argumenty (polozky ke kompresi)
echo "Zdroj: $*"
echo "Cil: $archiv"
tar cf - $* | 7zr a -t7z -m0=lzma2 -mx=9 -mmt=on -si $archiv
exit 0

