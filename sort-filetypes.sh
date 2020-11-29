#!/bin/bash

# Sort files by their type.

file="$1"
[ -f "$file" ] || { echo "File $file does not exist."; exit 1; }

#type="$(mimetype -biM "$file")"
type="$(file -b --mime-type "$file")"
#type="$(xdg-mime query filetype "$file")"

newpath="$file"
dir="$(dirname "$file")"
# Remove "./" from the path.
[ "${file:0:2}" == "./" ] && { newpath="${file:2}"; dir="${dir:2}"; }

mkdir -p "$type/$dir"
#echo "Moving $file to $type."
newpath="$type/$newpath"
mv -n -v "$file" "$newpath"

exit 0

