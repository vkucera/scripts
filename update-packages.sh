#!/bin/bash

# Update packages.

set -euo pipefail
set -o xtrace
sudo apt update
sudo apt upgrade
sudo apt autoremove
sudo apt clean
readarray -t packages < <(dpkg --get-selections | awk '$2 == "deinstall" {print $1}')
{ [[ ${#packages[@]} -gt 0 ]] && sudo dpkg --purge "${packages[@]}"; }
set +o xtrace
