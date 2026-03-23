#!/bin/bash

[[ "$#" != "4" ]] && { "Need check type, limit mode, token file, list of disks"; exit 1; }

CHECK="$1"
HARD="$2"
TOKEN_FILE="$3"
DISKS="$4"

[[ ! -f "${TOKEN_FILE}" ]] && { "Cannot find token file at ${TOKEN_FILE}"; exit 1; }

FILE_BASE="$HOME/monitor-logs"
[[ ! -d "$FILE_BASE" ]] && { mkdir -p "$FILE_BASE"; }

TITLE_WARNING="**:warning: $HOSTNAME warning**\n"

# Scheduled restart
TIME_RESTART="2026-03-15 08:00:00"
TIME_REMINDER_RESTART="10" # minutes before restart to send a reminder

# Maximum disk usage (%)
DISK_LIMIT_SOFT=95
DISK_LIMIT_HARD=98

# Minimum available memory fraction (%)
MEMORY_LIMIT_SOFT="10"
MEMORY_LIMIT_HARD="5"

notify_mattermost() {
  local text="$1"
  # echo -e "$text"
  # return 0
  local WEBHOOK
  WEBHOOK=$(cat "${TOKEN_FILE}")
  local COMMAND="curl -X POST -H 'Content-type: application/json' -d '{\"text\":\"${text}\"}' ${WEBHOOK}"
  eval "${COMMAND}"
}

check_memory() {
  local memory_total
  local memory_available
  local memory_min
  local message
  local logfile
  local report_once=1
  memory_total="$(free | grep Mem | awk '{print $2}')"
  memory_available="$(free | grep Mem | awk '{print $7}')"
  if [[ "$HARD" -eq 1  ]]; then
    logfile="${FILE_BASE}/memory_full"
    memory_min=$((MEMORY_LIMIT_HARD * memory_total / 100))
    message="${TITLE_WARNING}@all Available memory is almost **EXHAUSTED**: $((memory_available / 1048576)) GiB (threshold $((memory_min / 1048576)) GiB)"
  else
    logfile="${FILE_BASE}/memory_getting_full"
    memory_min=$((MEMORY_LIMIT_SOFT * memory_total / 100))
    message="${TITLE_WARNING}@all Available memory is low: $((memory_available / 1048576)) GiB (threshold $((memory_min / 1048576)) GiB)"
  fi
  if ((memory_available >= memory_min)); then
    rm -f "${logfile}"
    return 0
  fi
  if [[ -f "${logfile}" && "$report_once" -eq 1 ]]; then
    return 0
  fi
  date +"%F_%H-%M-%S" > "${logfile}"
  local text="${message}\n"
  text+="\n| user | usage [GiB] |\n|---|---|\n"
  text+="$(ps S -e --no-headers -o user:20,pss | awk '{m[$1] += $2; m["total"] += $2} END{for(u in m) {print u, m[u]}}' | sort -rnk 2 | head -5 | awk '{printf "| %s | %.0f |\\n", $1, $2 / 1048576}')"
  notify_mattermost "$text"
}

check_disk() {
  local path="$1"
  local space_used
  local space_max
  local message
  local logfile
  local report_once=1
  space_used=$(df "${path}" | awk '{print $5}' | tail -n1)
  space_used=${space_used%'%'}
  if [[ "$HARD" -eq 1 ]]; then
    logfile="${FILE_BASE}/${path}/disk_full"
    space_max=$DISK_LIMIT_HARD
    message="${TITLE_WARNING}@all Disk in ${path} is **FULL**: ${space_used} % (threshold ${space_max} %)"
  else
    logfile="${FILE_BASE}/${path}/disk_getting_full"
    space_max=$DISK_LIMIT_SOFT
    message="${TITLE_WARNING}@all Disk usage in ${path} is high: ${space_used} % (threshold ${space_max} %)"
  fi
  if ((space_used <= space_max)); then
    rm -f "${logfile}"
    return 0
  fi
  if [[ -f "${logfile}" && "$report_once" -eq 1 ]]; then
    return 0
  fi
  mkdir -p "${FILE_BASE}/${path}"
  date +"%F_%H-%M-%S" > "${logfile}"
  notify_mattermost "$message"
}

check_processes() {
  local table
  table="$(ps -e -o uid,user,lstart,rss,%cpu,state,comm -D "%Y%m%d" --sort=lstart | awk -v now="$(date +"%Y%m%d")" '{if (NR == 1) {$1=""; print} else if ($1 >= 1000 && $1 <= 60000 && $3 < now - 1 && ($4 > 1048576 || $5 > 10 || $6 == "T" || $6 == "Z")) {$1=""; print}}' | grep -Ev " (tmux)" | column -t | awk '{printf "%s\\n", $0}')"
  [[ "$(echo -e "$table" | wc -l)" -eq "2" ]] && return 0
  local users
  users="$(echo -e "$table" | awk '(NR > 1 && $0 != "") {users[$1] = 1} END{for (u in users) {printf "@%s ", u}}')"
  local header="${TITLE_WARNING}Suspicious old processes were found. Please check. ${users}\n\n\`\`\`\n"
  local footer="\`\`\`"
  notify_mattermost "${header}${table}${footer}"
}

restart() {
  local logfile="${FILE_BASE}/restart"
  local time_restart
  local now
  local before_restart
  time_restart="$(date +"%s" -d "${TIME_RESTART}")"
  now="$(date +"%s")"
  before_restart=$((now < time_restart))
  if [[ ! -f "${logfile}" ]]; then
    [[ $before_restart -eq 0 ]] && return 0
    notify_mattermost "${TITLE_WARNING}@all Restart of the system has been scheduled for ${TIME_RESTART}."
    echo "${TIME_RESTART}" > "${logfile}"
    return 0
  fi
  if [[ $before_restart -eq 1 ]]; then
    if ((time_restart - now <= 60 * TIME_REMINDER_RESTART)) && (($(wc -l < "${logfile}") == 1)); then
      notify_mattermost "${TITLE_WARNING}@all Restart of the system imminent at ${TIME_RESTART}."
      echo "${TIME_RESTART}" >> "${logfile}"
    fi
  elif ((time_restart <= $(date +"%s" -d "$(uptime -s)"))); then
    notify_mattermost "${TITLE_WARNING}@all Restart of the system at ${TIME_RESTART} was successful."
    rm -f "${logfile}"
  else
    notify_mattermost "${TITLE_WARNING}@all Restarting the system now."
    systemctl reboot
  fi
}

case "${CHECK}" in
  "disk")
    for disk in ${DISKS}; do
      check_disk "${disk}"
    done
  ;;
  "memory")
    check_memory
  ;;
  "processes")
    check_processes
  ;;
  "restart")
    restart
  ;;
esac
