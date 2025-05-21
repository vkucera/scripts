#!/bin/bash

# List packages installed from third-party repositories

array_contains() {
    local array="$1[@]"
    local seeking=$2
    for element in "${!array}"; do
        if [[ $element == "$seeking" ]]; then
            return 0
        fi
    done
    return 1
}

# Get list of installed packages
# shellcheck disable=SC2034
readarray -t installed < <(dpkg --get-selections | grep -v deinstall | awk '{ print $1 }')

# Get list of repository lists
lists="$(find /var/lib/apt/lists/*_Packages ! \( -name "*.ubuntu.com_ubuntu_*" -o -name "*.canonical.com_ubuntu_*" -o -name "*mirror.*_ubuntu_*" -o -name "*mirror.*_linuxmint_*" \))"

for list in $lists; do
    echo "==== $list"
    # Get list of packages in a given repository
    packages="$(grep ^Package "$list" | awk '{print $2}' | sort -u)"
    for p in $packages; do
        # echo "$p"
        # Check whether the package is installed
        if array_contains installed "$p"; then
            echo "$p"
        fi
        # https://documentation.ubuntu.com/server/explanation/software/third-party-repository-usage/
        # dpkg-query -W -f='${binary:Package}\t${db:Status-Abbrev}\n' "$p" 2> /dev/null | awk '/\tii $/{print $1}'
    done
done
