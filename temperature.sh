#!/bin/bash

# Print out date & time and CPU temperature(s).

ncores=$(($(nproc)/2))

declare -a temp

for i in $(seq 0 $(($ncores-1))); do
  temp[i]=$(sensors -u | grep "Core $i" -A 1 | grep temp | cut -d " " -f 4)
done
now=$(date +"%Y-%m-%d_%H-%M-%S");
echo $now ${temp[@]}

exit 0

