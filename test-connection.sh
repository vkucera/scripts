#!/bin/bash

# Test internet connection and display: date & time, loss fraction, average ping time

#domain="info.cern.ch"
domain="www.google.com"
count=10

now=$(date +%Y-%m-%d_%H-%M-%S)
result=$(ping -q -c $count $domain)
loss=$(echo $result | cut -d" " -f17)
ping="-1"

[[ "$loss" && "$loss" != "100%" ]] && ping=$(echo $result | cut -d/ -f5)
[ ! "$ping" ] && ping="-1"
[ ! "$loss" ] && loss="-1"
echo "$now loss $loss ping $ping ms"

exit 0

