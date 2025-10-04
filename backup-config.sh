#!/bin/bash

# Backup information about system configuration and programs settings.
# 2020-10-04

# shellcheck disable=SC2024

# Set bash strict mode.
set -euo pipefail

CodeName="$(lsb_release -cs)" # name of the Linux distro
DirThis="$(dirname "$(realpath "$0")")" # directory of this script
DirPath="${HOME}/config" # main directory with backups
TimeStamp="$(date +%Y-%m-%d_%H-%M-%S)" # unique identifier of this backup
TargetPath="${DirPath}/$HOSTNAME/$CodeName/$USER" # unique path of this backup
PathDotFile="${DirPath}/dot-backup.txt" # file with paths to programs settings

echo "Backing up configuration and settings"
echo "Output directory: ${TargetPath}"

[[ -f "$PathDotFile" ]] || { echo "File $PathDotFile does not exist."; exit 1; }

# Create output directory and delete its potential content.
mkdir -p "$TargetPath"
sudo chown -R "$USER":"$USER" "$TargetPath"
rm -rf "${TargetPath:?}"/*

# Initialise a Git repository if not present.
cd "$TargetPath"
( git branch > /dev/null 2>&1 || git init )

# System
echo "System"
TargetPathFull="${TargetPath}"/system
mkdir "$TargetPathFull"
cp -p /etc/lsb-release "$TargetPathFull"
#lsb_release -a "$TargetPathFull"/lsb_release.txt
cp -p /proc/cpuinfo "$TargetPathFull"
#cp -p /etc/issue "$TargetPathFull"
uname -a > "$TargetPathFull"/uname.txt
hostnamectl > "$TargetPathFull"/hostnamectl.txt
cp -p /etc/os-release "$TargetPathFull"
sudo dmidecode -q > "$TargetPathFull"/bios.txt
sudo lshw -short > "$TargetPathFull"/hw.txt
sudo lshw -html > "$TargetPathFull"/hw.html
lspci > "$TargetPathFull"/pci.txt
#ifconfig -a | grep HWadr > "$TargetPathFull"/mac.txt
inxi -Fxxxc0 > "$TargetPathFull"/inxi.txt

# Disk partitions
echo "Disk partitions"
TargetPathFull="${TargetPath}"/disk
mkdir "$TargetPathFull"
cp -p /etc/fstab "$TargetPathFull"
cp -p /etc/mtab "$TargetPathFull"
cp -p /etc/crypttab "$TargetPathFull"
sudo blkid > "$TargetPathFull"/blkid.txt
sudo fdisk -l > "$TargetPathFull"/fdisk.txt 2>&1
sudo parted -l > "$TargetPathFull"/parted.txt 2>&1
sudo df -H > "$TargetPathFull"/df.txt
cp -p /proc/mounts "$TargetPathFull"
mount | column -t > "$TargetPathFull"/mount.txt
cp -p /proc/partitions "$TargetPathFull"
cp -p /proc/swaps "$TargetPathFull"
lsblk > "$TargetPathFull"/lsblk.txt
ls -l /dev/disk/* > "$TargetPathFull"/dev.txt
cp -p /etc/default/grub "$TargetPathFull"
#sudo hdparm -i /dev/sda > "$TargetPathFull"/hdparm.txt

# Packages
echo "Packages"
TargetPathFull="${TargetPath}"/packages
mkdir "$TargetPathFull"
dpkg --get-selections > "$TargetPathFull"/dpkg-selections.txt
dpkg -l  > "$TargetPathFull"/dpkg-programs.txt
cp -p /var/cache/debconf/config.dat "$TargetPathFull"/
# PPA repositories
cp -p /etc/apt/sources.list "$TargetPathFull"
cp -pr /etc/apt/sources.list.d "$TargetPathFull"/
#sudo apt-key exportall > "$TargetPathFull"/repositories.keys
# grep -RoPish "ppa.launchpad.net/[^/]+/[^/ ]+" /etc/apt | sort -u | sed -r 's/\.[^/]+\//:/' > "$TargetPathFull"/ppa.txt
"$DirThis/list-third-party-packages.sh" > "$TargetPathFull"/third-party-packages.txt
# Snap packages
[[ -n "$(which snap)" ]] && { snap list > "$TargetPathFull"/snap.txt; }

# Network connections
echo "Network connections"
TargetPathFull="${TargetPath}"/network
for dir in "etc" "run"; do
if [[ -d "/$dir/NetworkManager/system-connections" ]]; then
  mkdir -p "$TargetPathFull"/"$dir"
  sudo cp -rp /$dir/NetworkManager/system-connections "$TargetPathFull"/"$dir"
else
  echo "- No $dir network connection settings found"
fi
done

# Printer settings
echo "Printer settings"
TargetPathFull="${TargetPath}"/printers
if [[ -f /etc/cups/printers.conf ]]; then
  mkdir "$TargetPathFull"
  sudo cp -p /etc/cups/printers.conf "$TargetPathFull"
else
  echo "- No printer settings found"
fi

# Programs settings
echo "Programs settings"
TargetPathFull="${TargetPath}"/programs
mkdir "$TargetPathFull"
IFS=$'\n' # needed to avoid splitting strings with spaces
while read -r i; do
  DirI="$(dirname "${i}")"
  DirITarget="$TargetPathFull"/"$DirI"
  mkdir -p "$DirITarget"
  cp -rp "$HOME/${i}" "$DirITarget"
done < "$PathDotFile"
unset IFS

# Firefox data
echo "Firefox"
TargetPathFull="${TargetPath}"/firefox
"$DirThis/backup-firefox.sh" "$TargetPathFull"

# Adjust ownership of the backup content.
sudo chown -R "$USER":"$USER" "$TargetPath"

# Commit
echo "Creating a commit: $TimeStamp"
cd "$TargetPath"
git add -A
git commit -m "$TimeStamp"
git tag -a "$TimeStamp" -m "$TimeStamp"

echo "Done"
