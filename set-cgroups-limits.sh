#!/bin/bash

# Set cgroups limits.

# Set bash strict mode.
set -euo pipefail

device="$(hostname)"
case "$device" in
  "alicecerno2")
    versionCGroups=1
    ramMax=770690780160
    cpuMax=9500000
    ioWriteMax=660602880
    ioReadMax=1887436800
    partition="8:0"
    ;;
  "alipap1")
    versionCGroups=2
    ramMax=384880619315
    cpuMax=9500000
    ioWriteMax=471859200
    ioReadMax=1038090240
    partition="8:0"
    ;;
  "aliceml")
    versionCGroups=2
    ramMax=385122671411
    cpuMax=5500000
    ioWriteMax=471859200
    ioReadMax=1226833920
    partition="8:96"
    ;;
  *)
    echo "Not a known device!"
    exit 1
    ;;
esac

setLimit() {
  limit="$1"
  file="$2"
  [[ -f "$file" ]] || { echo "File $file does not exist."; return; }
  # set -o xtrace
  echo "$limit" > "$file"
  # set +o xtrace
  echo "$file"
  cat "$file"
}

echo "Setting cgroups (v$versionCGroups) limits for $device"

if [[ $versionCGroups -eq 1 ]]; then
  # cgroups v1
  # RAM
  setLimit "$ramMax" /sys/fs/cgroup/memory/user.slice/memory.limit_in_bytes
  # CPU
  setLimit "$cpuMax" /sys/fs/cgroup/cpu/user.slice/cpu.cfs_quota_us
  # IO
  setLimit "$partition $ioWriteMax" /sys/fs/cgroup/blkio/user.slice/blkio.throttle.write_bps_device
  setLimit "$partition $ioReadMax" /sys/fs/cgroup/blkio/user.slice/blkio.throttle.read_bps_device
elif [[ $versionCGroups -eq 2 ]]; then
  # cgroups v2
  # enable controllers
  setLimit "+memory +cpu +io" /sys/fs/cgroup/cgroup.subtree_control
  setLimit "+memory +cpu +io" /sys/fs/cgroup/user.slice/cgroup.subtree_control
  # RAM
  setLimit "$ramMax" /sys/fs/cgroup/user.slice/memory.max
  # CPU
  setLimit "$cpuMax" /sys/fs/cgroup/user.slice/cpu.max
  # IO
  setLimit "$partition wbps=$ioWriteMax rbps=$ioReadMax" /sys/fs/cgroup/user.slice/io.max
else
  echo "Unsupported version of cgroups $versionCGroups"
  exit 1
fi
