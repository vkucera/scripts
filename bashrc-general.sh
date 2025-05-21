#!/bin/bash

# general

# environment

eval "$(direnv hook "$SHELL")"
export PATH="$HOME/.local/bin:$PATH"

alias q='exit'
alias time='/usr/bin/time -f "time real: %E\ntime real: %e s\ntime kernel: %S s\ntime user: %U s\nCPU: %P\nMemory (max): %M kB\nExit code: %x"'
alias htopme='htop -u $USER'
alias du='du --si'

# utils

# Upgrade packages
update-sw() {
  set -euo pipefail
  set -o xtrace
  sudo apt update
  sudo apt upgrade
  sudo apt autoremove
  sudo apt clean
  readarray -t packages < <(dpkg --get-selections | awk '$2 == "deinstall" {print $1}')
  { [[ ${#packages[@]} -gt 0 ]] && sudo dpkg --purge "${packages[@]}"; }
  set +o xtrace
}

speed() {
  device=$(ifconfig -s | grep BMRU | awk '{print $1}')
  if [[ -z "$device" ]]; then
    echo "No device found"
    return 1
  fi
  if [[ -n "$(which speedometer)" ]]; then
    speedometer -r "$device" -t "$device"
  else
    echo "speedometer not found"
  fi
}

test-write() {
  [ "$1" ] || { echo "Provide a number"; return 1; }
  n_max=$1
  file=$(date +"%Y-%m-%d-%H-%M-%S")
  echo "Writing $n_max numbers to $file..."
  [ -f "$file" ] && { echo "Error: File $file already exists."; return 1; }
  start=$(date +%s)
  for n in $(seq "$n_max")
    do echo "$n" >> "$file"
  done
  echo "File has $(du -s --si "$file")."
  cp "$file" "${file}_"
  rm "$file" "${file}_"
  end=$(date +%s)
  echo "Took $((end - start)) seconds."
}
