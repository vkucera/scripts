#!/bin/bash

# Backup information about system configuration and programs settings.
# 2020-10-04

CodeName="$(lsb_release -cs)" # name of the Linux distro
DirPath="${HOME}/config" # main directory with backups
TimeStamp="$(date +%Y-%m-%d_%H-%M-%S)" # unique identifier of this backup
TargetPath="${DirPath}/$HOSTNAME/$CodeName/$USER" # unique path of this backup
PathDotFile="${DirPath}/dot-backup.txt" # file with paths to programs settings

function ErrExit { echo "Error"; exit 1; }

echo "Backing up configuration and settings"
echo "Output directory: ${TargetPath}"

[ -f "$PathDotFile" ] || { echo "File $PathDotFile does not exist."; ErrExit; }

# Create output directory and delete its potential content.
mkdir -p "$TargetPath" && \
sudo chown -R $USER:$USER "$TargetPath" && \
rm -rf $TargetPath/* || ErrExit

# Initialise a Git repository if not present.
cd "$TargetPath" && \
( git branch > /dev/null 2>&1 || git init ) || ErrExit

# System
echo "System"
mkdir ${TargetPath}/system && \
cp -p /etc/lsb-release ${TargetPath}/system && \
#lsb_release -a ${TargetPath}/system/lsb_release.txt
cp -p /proc/cpuinfo ${TargetPath}/system && \
#cp -p /etc/issue ${TargetPath}/system
uname -a > ${TargetPath}/system/uname.txt && \
sudo dmidecode -q > ${TargetPath}/system/bios.txt && \
sudo lshw -short > ${TargetPath}/system/hw.txt && \
lspci > ${TargetPath}/system/pci.txt && \
sudo lshw -html > ${TargetPath}/system/hw.html && \
#ifconfig -a | grep HWadr > ${TargetPath}/system/mac.txt
inxi -Fxxxc0 > ${TargetPath}/system/inxi.txt || ErrExit

# Disk partitions
echo "Disk partitions"
mkdir ${TargetPath}/disk && \
cp -p /etc/fstab ${TargetPath}/disk && \
cp -p /etc/mtab ${TargetPath}/disk && \
cp -p /etc/crypttab ${TargetPath}/disk && \
sudo blkid > ${TargetPath}/disk/blkid.txt && \
sudo fdisk -l > ${TargetPath}/disk/fdisk.txt 2>&1 && \
sudo parted -l > ${TargetPath}/disk/parted.txt 2>&1 && \
df -H > ${TargetPath}/disk/df.txt && \
cp -p /proc/mounts ${TargetPath}/disk && \
mount | column -t > ${TargetPath}/disk/mount.txt && \
cp -p /proc/partitions ${TargetPath}/disk && \
cp -p /proc/swaps ${TargetPath}/disk && \
sudo hdparm -i /dev/sda > ${TargetPath}/disk/hdparm.txt && \
lsblk > ${TargetPath}/disk/lsblk.txt || ErrExit

# Packages
echo "Packages"
mkdir ${TargetPath}/packages && \
dpkg --get-selections > ${TargetPath}/packages/dpkg-selections.txt && \
dpkg -l  > ${TargetPath}/packages/dpkg-programs.txt && \
# PPA repositories
cp -p /etc/apt/sources.list ${TargetPath}/packages && \
cp -pr /etc/apt/sources.list.d ${TargetPath}/packages/ && \
#sudo apt-key exportall > ${TargetPath}/packages/repositories.keys
grep -RoPish "ppa.launchpad.net/[^/]+/[^/ ]+" /etc/apt | sort -u | sed -r 's/\.[^/]+\//:/' > ${TargetPath}/packages/ppa.txt || ErrExit
# Snap packages
[ ! -z $(which snap) ] && { snap list > ${TargetPath}/packages/snap.txt || ErrExit; }

# Network connections
echo "Network connections"
mkdir ${TargetPath}/network && \
sudo cp -rp /etc/NetworkManager/system-connections ${TargetPath}/network || ErrExit

# Printer settings
echo "Printer settings"
if [ -f /etc/cups/printers.conf ]; then
  mkdir ${TargetPath}/printers && \
  sudo cp -p /etc/cups/printers.conf ${TargetPath}/printers || ErrExit
else
  echo "- No printer settings found"
fi

# Programs settings
echo "Programs settings"
IFS=$'\n' # needed to avoid splitting strings with spaces
mkdir ${TargetPath}/programs && \
for i in $(cat $PathDotFile); do
  DirI="$(dirname "${i}")" && \
  DirITarget="${TargetPath}/programs/$DirI" && \
  mkdir -p "$DirITarget" && \
  cp -rp "$HOME/${i}" "$DirITarget" || ErrExit
done || ErrExit
unset IFS

# Firefox data
echo "Firefox"
"$(dirname $(realpath $0))"/backup-firefox.sh ${TargetPath}/firefox || ErrExit

# Adjust ownership of the backup content.
sudo chown -R $USER:$USER "$TargetPath" || ErrExit

# Commit
echo "Creating a commit: $TimeStamp"
cd "$TargetPath" && \
git add -A && \
git commit -m "$TimeStamp" && \
git tag -a "$TimeStamp" -m "$TimeStamp" || ErrExit

echo "Done"

exit 0
