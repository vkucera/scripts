#!/bin/bash

# Add a new user with passwordless login, expiry date and disk quota
# Execute with sudo

# Set bash strict mode.
set -euo pipefail

fullname=""
username=""
key=""
expiry=""
user_default="vkucera"  # user to copy the disk quota from

# Print out a help message.
Help() {
  echo "Usage: sudo $(basename "$0") -n \"FULL_NAME\" -u USER_NAME -k KEY_FILE -e EXPIRY_DATE [-h]"
  echo "FULL_NAME    Full name of the user"
  echo "USER_NAME    User name"
  echo "KEY_FILE     Path to the public SSH key"
  echo "EXPIRY_DATE  Account expiry date in format YYYY-MM-DD"
}

# Parse command line options.
while getopts ":hn:u:k:e:" opt; do
  case ${opt} in
    h)
      Help; exit 0;;
    n)
      fullname="$OPTARG";;
    u)
      username="$OPTARG";;
    k)
      key="$OPTARG";;
    e)
      expiry="$OPTARG";;
    \?)
      echo "Error: Invalid option: $OPTARG" 1>&2; Help; exit 1;;
    :)
      echo "Error: Invalid option: $OPTARG requires an argument." 1>&2; Help; exit 1;;
  esac
done

# Check that the script is executed by root
[ "$USER" == "root" ] || { echo "Error: Run this script as root" 1>&2; exit 1; }

# Sanitise input parameters
[ "$fullname" ] || { echo "Error: Provide a person's name" 1>&2; exit 1; }
[ "$username" ] || { echo "Error: Provide a user name" 1>&2; exit 1; }
[ "$key" ] || { echo "Error: Provide a key file path" 1>&2; exit 1; }
[ -f "$key" ] || { echo "Error: Provide a valid key file path" 1>&2; exit 1; }
[ "$expiry" ] || { echo "Error: Provide an expiry date" 1>&2; exit 1; }

# Print summary
echo "Adding user \"$username\" for person \"$fullname\" with SSH key $key and expiry date $expiry."

# Ask for confirmation
echo -e "\nDo you wish to continue? (y/n)"
while true; do
  read -r -p "Answer: " yn
  case $yn in
    [y] ) echo "Proceeding"; break;;
    [n] ) echo "Aborting";  exit 0;;
    * ) echo "Please answer y or n.";;
  esac
done

# Do everything and exit at the first error
echo "Creating user $username for $fullname" && \
adduser --disabled-password --gecos "$fullname" "$username" && \
dir_ssh="/home/$username/.ssh" && \
echo "Copying key $key into $dir_ssh" && \
rsync -t "$key" "$dir_ssh/" && \
rsync -t "$key" "$dir_ssh/authorized_keys" && \
chown -R "$username":"$username" "$dir_ssh" && \
echo "Setting expiry date $expiry" && \
chage -E "$expiry" "$username" && \
echo "Setting disk quota" && \
edquota -p "$user_default" "$username" && \
{ echo "All done"; exit 0; } || { echo "Error"; exit 1; }
