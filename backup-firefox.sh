#!/bin/bash

# Backup Firefox settings for each profile.
# 2020-10-04

echo "Firefox backup"

TargetDir="$1"
[ -z "$TargetDir" ] && { echo "Please provide a path for the files."; exit 1; }

FirefoxDir="$HOME/.mozilla/firefox"

if [[ ! -d "$FirefoxDir" ]]; then
  echo "- No Firefox settings found"
  exit 0
fi

# Find paths to all existing profiles
IFS=$'\n' # needed to avoid splitting strings with spaces
grep Path "$FirefoxDir/profiles.ini" | cut -d= -f2 | while IFS= read -r Profile; do
  #echo "Profile $Profile"
  mkdir -p "$TargetDir/$Profile"
  # Bookmarks
  LastFile=$(find "$FirefoxDir/$Profile/bookmarkbackups/" -type f | sort | tail -1)
  [ "$LastFile" ] && cp -p "$LastFile" "$TargetDir/$Profile" || echo "No bookmarks found for profile $Profile."
  # Extensions
  find "$FirefoxDir/$Profile/extensions" -maxdepth 1 -name "*.xpi" -exec basename {} \; | sort > "$TargetDir/$Profile/extensions.txt"
done
unset IFS

exit 0
