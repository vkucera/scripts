#!/bin/bash

# alice-admin

# Stats for fmq files in shared memory
shm() {
  echo -n "Shared memory usage: "
  du -s --si /dev/shm 2> /dev/null
  echo -n "FMQ files: "
  find /dev/shm/ -maxdepth 1 -type f -name "*fmq*" -print0 | du -c --si --files0-from=- | tail -n 1
  echo "By user:"
  users=$(find /dev/shm/ -maxdepth 1 -type f -name "*fmq*" -exec stat -c "%U" {} \; | sort -u)
  for u in $users; do echo -n "$u "; find /dev/shm/ -maxdepth 1 -type f -name "*fmq*" -user "$u" -print0 | du -c --si --files0-from=- | tail -n 1; done
  echo "Delete files with: sudo find /dev/shm/ -maxdepth 1 -type f -name \"*fmq*\" -delete"
}

# Stats for O2 sockets
sockets() {
  echo -n "Number of socket files: "
  find /tmp/ -maxdepth 1 -type s -name "localhost*" | wc -l
  echo "By user:"
  users=$(find /tmp/ -maxdepth 1 -type s -name "localhost*" -exec stat -c "%U" {} \; | sort -u)
  for u in $users; do echo -n "$u "; find /tmp/ -maxdepth 1 -type s -name "localhost*" -user "$u" | wc -l; done
  echo "Delete files with: sudo find /tmp/ -maxdepth 1 -type s -name \"localhost*\" -delete"
}

# Size of directories with O2 input files
aod() { find /home/ -type f -name "AO*D*.root" -print0 2> /dev/null | du -c --si --files0-from=- | tail -n 1; }

# Size of alice/sw directories by user, sorted by size
builds() {
  find /home/ -maxdepth 5 -type d -name "BUILD" -exec du -s --si {}/.. \;  2> /dev/null | sort -h
}

# Sort package directories with multiple builds by size
# $1 is a path to an sw directory.
builds-size() {
  [ "$1" ] || { echo "Provide a path to an sw directory"; return; }
  for f in "$1"/ubuntu2004_x86-64/*/; do
    echo "$(du -s --si "$f") $(find "$f" -mindepth 1 -maxdepth 1 -type d | wc -l) ";
  done | grep -v " 1 " | sort -h
}

# Sort package directories with multiple builds by number of builds
# $1 is a path to an sw directory.
builds-number() {
  [ "$1" ] || { echo "Provide a path to an sw directory"; return; }
  for f in "$1"/ubuntu2004_x86-64/*/; do
    echo "$(find "$f" -mindepth 1 -maxdepth 1 -type d | wc -l) $f"
  done | grep -v "1 " | sort -h
}
