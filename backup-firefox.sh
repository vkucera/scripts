#!/bin/bash

# Backup Firefox settings for each profile.
# 2020-10-04

echo "Firefox backup"

TargetDir="$1"
[ -z $TargetDir ] && { echo "Please provide a path for the files."; exit 1; }

FirefoxDir="$HOME/.mozilla/firefox"

# Find paths to all existing profiles
IFS=$'\n' # needed to avoid splitting strings with spaces
for Profile in $(grep Path $FirefoxDir/profiles.ini | cut -d= -f2); do
  #echo "Profile $Profile"
  mkdir -p "$TargetDir/$Profile"
  # Bookmarks
  LastFile=$(find $FirefoxDir/$Profile/bookmarkbackups/ -type f | sort | tail -1)
  [ "$LastFile" ] && cp -p "$LastFile" "$TargetDir/$Profile" || echo "No bookmarks found for profile $Profile."
done
unset IFS

exit 0
