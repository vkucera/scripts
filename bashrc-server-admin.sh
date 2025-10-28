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
  [ "$1" ] || { echo "Provide a number of days"; return 1; }
  for u in $(get-users | sort); do
    [ "$(sudo find "/home/$u" -mtime -"$1" -print -quit | wc -l)" -eq 0 ] && echo "$u"
  done
}

# Show list of home directories inactive in the last N days, sorted by size
# $1 is the minimum number of inactive days N
inactive-users-size() {
  [ "$1" ] || { echo "Provide a number of days"; return 1; }
  readarray -t list_users < <(inactive-users "$1")
  echo "${list_users[@]}"
  cd /home && sudo du -sc --si "${list_users[@]}" | sort -h
  cd - || exit
}

# Check whether there is at least frac_min of total memory available.
memory-ok() {
  [ "$1" ] || { echo "Provide the minimum memory fraction"; return 1; }
  frac_min="$1"
  return "$(free | grep Mem | awk -v frac_min="$frac_min" '{print ($7 < $2 * frac_min) ? 1 : 0}')";
}

# Show n_proc processes taking the most memory.
get-big-processes() {
  n_proc=10
  [ "$1" ] && { n_proc=$1; }
  ps S -e -o user:20,pid,%cpu,rss,comm,start --sort=-rss | head -n $((n_proc + 1))
}

# Show the process taking the most memory for each user.
get-big-processes-per-user() {
  ps S -e -o user:20,pid,%cpu,rss,comm,start --sort=-rss | awk '{if (NR == 1) {print $0, "RSS [GiB]"} else {if (!($1 in m)) {m[$1] = 1; print $0, $4/1048576}}}'
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

# Get the memory taken by a given user.
# Run with 'sudo bash -c "source bashrc-server-admin.sh && get-user-memory <user>"'.
get-user-memory() {
  [[ -z "$1" ]] && { echo "Provide username."; return 1; }
  user="$1"
  ps S -u "$user" --no-headers -o pss | awk '{m += $1} END{print m, m/1048576, "GiB"}'
}

# Get the memory taken by each user.
# Run with 'sudo bash -c "source bashrc-server-admin.sh && get-memory-per-user"'.
# Faster than "sudo smem -ukta -c "user pss" -r pss".
get-memory-per-user() {
  ps S -e --no-headers -o user:20,pss | awk '{m[$1] += $2; m["total"] += $2} END{for(u in m) {print u, m[u], m[u]/1048576, "GiB"}}' | sort -rnk 2 | column -t
}

# Log the memory taken by each user.
# Run with 'sudo bash -c "source bashrc-server-admin.sh && log-memory-per-user <file> [interval] [mem_min]"'.
log-memory-per-user() {
  [[ -z "$1" ]] && { echo "Provide log file name."; return 1; }
  logfile="$1"
  interval=10
  [ "$2" ] && { interval="$2"; }
  mem_min="0.2"
  [ "$3" ] && { mem_min="$3"; }
  echo "Logging user memory in \"$logfile\" every $interval s (min. memory fraction $mem_min)..."
  while true; do
    echo
    date +"%F_%H-%M-%S"
    get-memory-per-user
    memory-ok "$mem_min" || { echo; date +"%F_%H-%M-%S"; get-big-processes-per-user; } >> "big_processes_$logfile"
    sleep "$interval"
  done >> "$logfile"
}
