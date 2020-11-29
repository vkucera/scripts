#!/bin/bash

# Extract all URLs in the input file.
# 2019-11-25

sed -e "s/http/\nhttp/g" "$1" | grep http | grep :// | cut -d "\"" -f 1 | cut -d " " -f 1 | cut -d "<" -f 1 | sort -u
exit 0

