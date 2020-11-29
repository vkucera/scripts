#!/bin/bash

# Rename hidden files/directories so that their names don't start with dot.
# 2018-01-15

path="$1"

if [ ! -e "$path" ]; then
  >&2 echo "The file/directory $path does not exist."
  exit 1
fi

if [ "$path" == "." ] || [ "$path" == ".." ]; then
  echo "Ignoring the current and the parent directories."
  exit 0
fi

basedir="$(dirname "$path")"
file="$(basename "$path")"

# Skip file/directory names that do not start with dot.
if [ "${file:0:1}" != "." ]; then
  echo "Name $file does not start with dot. Skipping."
  exit 0
fi

newpath="$basedir/${file:1}" # Remove the first character, i.e. dot.

if [ -e "$newpath" ]; then
  >&2 echo "File/directory $newpath already exists. Cannot rename."
  exit 1
else
  echo "Renaming $path to $newpath"
  mv "$path" "$newpath"
  exit 0
fi
