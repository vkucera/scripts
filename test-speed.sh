#!/bin/bash

# Measure internet connection speed.
# Display: date & time, ping, download speed, upload speed.

now=$(date +%Y-%m-%d_%H-%M-%S)
result=$(speedtest-cli --simple)
echo $now $result

exit 0

