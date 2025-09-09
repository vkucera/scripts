#!/bin/bash

# Replace all strings old with string new in file.

old=$1
new=$2
file=$3

sed -e "s|${old}|${new}|g" "${file}" > "${file}.tmp" && mv "${file}.tmp" "${file}"
exit 0
