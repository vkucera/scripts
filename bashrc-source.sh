#!/bin/bash

# Put this in ~/.bashrc.

# Source bash utilities.
path_to_scripts="$HOME/code/scripts"
for file in general alice alice-admin server-admin; do
  script="${path_to_scripts}/bashrc-${file}.sh"
  if [[ -f "$script" ]]; then
    # shellcheck disable=SC1090
    source "$script"
  fi
done
