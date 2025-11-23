#!/bin/bash

# general

# environment

[[ -n "$(which direnv)" ]] && eval "$(direnv hook "$SHELL")"
export PATH="$HOME/.local/bin:$PATH"
export PYTHONUSERBASE="$HOME/user_python"
export PATH="$PYTHONUSERBASE/bin:$PATH"

alias q='exit'
alias time='/usr/bin/time -f "time real: %E\ntime real: %e s\ntime kernel: %S s\ntime user: %U s\nCPU: %P\nMemory (max): %M kB\nExit code: %x"'
alias htopme='htop -u $USER'
alias du-si='du --si'
alias power-off-disk="udisksctl power-off -b"
alias time='/usr/bin/time -f "time real: %E\ntime real: %e s\ntime kernel: %S s\ntime user: %U s\nCPU: %P\nMemory (max): %M kB\nExit code: %x"'
alias update-firmware="fwupdmgr get-devices && fwupdmgr refresh --force && fwupdmgr get-updates && fwupdmgr update"

# utils

# Monitor speed of internet connection.
speed() {
  [[ -z "$(which speedometer)" ]] && { echo "speedometer not found"; return 1; }
  device=$(ifconfig -s | grep BMRU | awk '{print $1}')
  [[ -z "$device" ]] && { echo "No device found"; return 1; }
  speedometer -r "$device" -t "$device"
}

# Check write speed.
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
