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
readarray -t installed < <(dpkg --get-selections | grep -v deinstall | awk '{print $1}')

# Get the distro name and URLs of official repos.
name_distro="$(grep ^DISTRIB_ID /etc/lsb-release | cut -d= -f2)"
case "${name_distro}" in
    "LinuxMint")
        file_repos="/etc/apt/sources.list.d/official-package-repositories.list"
        mapfile -t urls_official < <(awk '{print $2}' "${file_repos}" | sort -u | grep ^http | cut -d/ -f3)
        ;;
    "Ubuntu")
        file_repos="/etc/apt/sources.list.d/ubuntu.sources"
        mapfile -t urls_official < <(awk '$1 == "URIs:" {print $2}' ${file_repos} | sort -u | grep ^http | cut -d/ -f3)
        ;;
esac

# Get list of repository lists
mapfile -t lists < <(find /var/lib/apt/lists/*_Packages)

for list in "${lists[@]}"; do
    skip=0
    # Exclude official repos.
    for url in "${urls_official[@]}"; do
        # echo "Checking if $url is in $list"
        if [[ "$list" == *"$url"* ]]; then
            skip=1
            break
        fi
    done
    if [[ $skip -eq 1 ]]; then
        # echo Skipping
        continue
    fi
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
