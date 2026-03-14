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
  local message=""
  memory_total="$(free | grep Mem | awk '{print $2}')"
  memory_available="$(free | grep Mem | awk '{print $7}')"
  local notify=0
  if [[ "$HARD" -eq 1  ]]; then
    local logfile="${FILE_BASE}/${path}/memory_full"
    memory_min=$((MEMORY_LIMIT_HARD * memory_total / 100))
    if ((memory_available < memory_min)); then
      [[ -f "${logfile}" ]] && return 0
      message="${TITLE_WARNING}@all Available memory is almost **EXHAUSTED**: $((memory_available/1048576)) GiB (threshold $((memory_min/1048576)) GiB)"
      notify=1
      date +"%F_%H-%M-%S" > "${logfile}"
    else
      rm -f "${logfile}"
    fi
  else
    memory_min=$((MEMORY_LIMIT_SOFT * memory_total /100))
    if ((memory_available < memory_min)); then
      message="${TITLE_WARNING}@all Available memory is low: $((memory_available/1048576)) GiB (threshold $((memory_min/1048576)) GiB)"
      notify=1
    fi
  fi
  if [[ $notify -eq 1 ]]; then
    local text="${message}\n"
    text+="\n| user | usage [GiB] |\n|---|---|\n"
    text+="$(ps S -e --no-headers -o user:20,pss | awk '{m[$1] += $2; m["total"] += $2} END{for(u in m) {print u, m[u]}}' | sort -rnk 2 | head -5 | awk '{printf "| %s | %.0f |\\n", $1, $2/1048576}')"
    notify_mattermost "$text"
  fi
}

check_disk() {
  local path="$1"
  local disk_use
  disk_use=$(df "${path}" | awk '{print $5}' | tail -n1)
  disk_use=${disk_use%'%'}
  if [[ "$HARD" -eq 1 ]]; then
    local logfile="${FILE_BASE}/${path}/disk_full"
    mkdir -p "${FILE_BASE}/${path}"
    if ((disk_use > DISK_LIMIT_HARD)); then
      [[ -f "${logfile}" ]] && return 0
      notify_mattermost "${TITLE_WARNING}@all Disk in ${path} is **FULL**: ${disk_use} % (threshold ${DISK_LIMIT_SOFT} %)"
      date +"%F_%H-%M-%S" > "${logfile}"
    else
      rm -f "${logfile}"
    fi
  else
    if ((disk_use > DISK_LIMIT_SOFT)); then
      notify_mattermost "${TITLE_WARNING}@all Disk usage in ${path} is high: ${disk_use} % (threshold ${DISK_LIMIT_SOFT} %)"
    fi
  fi
}

check_processes() {
  local table
  table="$(ps -e -o uid,user,lstart,rss,%cpu,state,comm -D "%Y%m%d" --sort=lstart | awk -v now="$(date +"%Y%m%d")" '{if (NR == 1) {$1=""; print} else if ($1 >= 1000 && $1 <= 60000 && $3 < now - 1 && ($4 > 1048576 || $5 > 10 || $6 == "T" || $6 == "Z")) {$1=""; print}}' | column -t | awk '{printf "%s\\n", $0}')"
  [[ "$(echo -e "$table" | wc -l)" -eq "2" ]] && return 0
  local users
  users="$(echo -e "$table" | awk '(NR > 1 && $0 != "") {users[$1] = 1} END{for (u in users) {printf "@%s ", u}}')"
  local header="${TITLE_WARNING}Suspicious old processes were found. Please check. ${users}\n\n\`\`\`\n"
  local footer="\`\`\`"
  notify_mattermost "${header}${table}${footer}"
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
esac
