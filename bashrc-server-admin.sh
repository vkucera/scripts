#!/bin/bash

# server-admin

# Get list of users
get-users() {
  # https://www.cyberciti.biz/faq/linux-list-users-command/
  _l="/etc/login.defs"
  _p="/etc/passwd"

  ## get mini UID limit ##
  l=$(grep "^UID_MIN" $_l)

  ## get max UID limit ##
  l1=$(grep "^UID_MAX" $_l)

  ## use awk to print if UID >= $MIN and UID <= $MAX and shell is not /sbin/nologin   ##
  awk -F':' -v "min=${l##UID_MIN}" -v "max=${l1##UID_MAX}" '{ if ( $3 >= min && $3 <= max  && $7 != "/sbin/nologin" ) print $1 }' "$_p"
}

# For each user show: user name, person's name, date of last log in, size of home directory
users-summary() {
  fsHome="$(df /home | tail -n 1 | awk '{print $1}')"  # partition with the /home directory
  today="$(date -I)" # YYYY-MM-DD
  nCharsLast=69  # minimum number of characters in the output of lastlog to skip to isolate the date
  # Print the header.
  echo "User name;Person's name;Last login;Expires;Size;Status"
  for u in $(get-users | sort); do
    # Get the person's name
    name=$(getent passwd "$u" | cut -d: -f5 | cut -d, -f1)
    # Get the date of last login
    last=$(lastlog -u "$u" | tail -n 1)
    last="$(lastlog -u "$u" | tail -n 1)"
    last="${last:$nCharsLast}"
    last_day="$(echo "$last" | awk '{printf("%s %s\n", $2, $3)}')"
    last_year="$(echo "$last" | awk '{print $6}')"
    [ "$last_year" ] && last="$last_year $last_day" || last="never"
    # Get the occupied disk space on the /home partition.
    size=$(sudo quota -s -u "$u" | grep "$fsHome" | awk '{print $2}')
    # Get the expiry date (YYYY-MM-DD)
    expire=$(sudo chage -li "$u" | sed -n 4p | cut -d: -f2 | cut -d" " -f2)
    # Check whether the account expired.
    comment=""
    [[ "$expire" != "never" && ${expire//-/} -lt ${today//-/} ]] && comment="expired"
    # Print the full line.
    echo -e "$u;$name;$last;$expire;$size;$comment"
  done
}

# Show disk space overall and by user
disk() {
  echo "Disk space usage:"
  df -H /
  echo "By user:"
  sudo du -sc --si /home/* 2> /dev/null | sort -h
}

# Show list of home directories inactive in the last N days
# $1 is the minimum number of inactive days N
inactive-users() {
  [ "$1" ] || { echo "Provide a number of days"; return; }
  for u in $(get-users | sort); do
    [ "$(sudo find "/home/$u" -mtime -"$1" -print -quit | wc -l)" -eq 0 ] && echo "$u"
  done
}

# Show list of home directories inactive in the last N days, sorted by size
# $1 is the minimum number of inactive days N
inactive-users-size() {
  [ "$1" ] || { echo "Provide a number of days"; return; }
  readarray -t list_users < <(inactive-users "$1")
  echo "${list_users[@]}"
  cd /home && sudo du -sc --si "${list_users[@]}" | sort -h
  cd - || exit
}

# Show N processes taking the most memory.
get-big-processes() {
  n_proc=10
  [ "$1" ] && { n_proc=$1; }
  ps -e S -o user,pid,start,%cpu,%mem,rss,comm --sort=-rss | head -n $((n_proc + 1))
}

# Get the number of processes per user and open htop for each user.
get-user-processes() {
  for u in $(get-users); do
    n=$(ps -u "$u" -o user | wc -l)
    if [[ $n -gt 1 ]]; then
      echo "$u $((n - 1))"
      htop -u "$u"
    fi
  done
}

# Get the estimate of memory taken by the user.
get-user-memory() {
  [[ -z "$1" ]] && { echo "Provide username."; return 1; }
  user="$1"
  ps S -U "$user" --no-headers -o rss | awk '{m+=$1} END{print m}'
}

# Get the estimate of memory taken by processes per user.
get-memory-per-user() {
  total=0
  {
  for u in $(ps -e --no-headers -o user | sort -u); do
    m=$(get-user-memory "$u")
    if [[ $m -gt 0 ]]; then
      echo "$u $(echo "scale=3; $m/1048576" | bc) GiB"
      total=$((total + m))
    fi
  done
  echo "total $(echo "scale=3; $total/1048576" | bc) GiB"
  } | sort -rnk 2 | column -t
}

# Log the estimate of memory taken by processes per user.
log-memory-per-user() {
  [[ -z "$1" ]] && { echo "Provide log file name."; return 1; }
  logfile="$1"
  interval=10
  while true; do
    echo
    date +"%F_%H-%M-%S"
    get-memory-per-user
    sleep $interval
  done >> "$logfile"
}
