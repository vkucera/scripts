#!/bin/bash

# alice

export ALIBUILD_WORK_DIR="$HOME/alice/sw"
export PYTHONUSERBASE="$HOME/user_python"
export PATH="$PYTHONUSERBASE/bin:$PATH"
eval "$(alienv shell-helper)"

alias loadali='alienv enter AliPhysics/latest'
alias loado2='alienv enter O2/latest'
alias loado2p='alienv enter O2Physics/latest'
alias root='root -l'

# ninja recompilation
recompile() {
  # set -o xtrace
  [ "$1" ] || { echo "Provide a package name"; return 1; }
  branch="master"
  [ "$2" ] && branch="$2"
  target=""
  target_name="all"
  [ "$3" ] && { target="$3/"; target_name="$3"; }
  dir_pwd=$(pwd)
  dir_build="$ALIBUILD_WORK_DIR/BUILD/$1-latest-${branch}/$1"
  log="$(dirname "$dir_build")/log"
  log_err="$(dirname "$dir_build")/log_err"
  cd "$dir_build" || { echo "Could not enter $dir_build"; return 1; }
  direnv allow || { echo "Failed to allow direnv"; return 1; }
  eval "$(direnv export "$SHELL")"
  echo "Recompiling ${1}_${branch}_${target_name}..."
  start=$(date +%s)
  ninja "${target}install" > "$log" 2>&1
  ec=$?
  end=$(date +%s)
  echo "Compilation exited with: $ec"
  echo "See the log at: $log"
  if [ "$ec" != "0"  ]; then
    grep -e "FAILED:" -e "error:" "$log" > "$log_err"
    echo "See the errors at: $log_err"
  fi
  echo "Took $((end - start)) seconds."
  cd "$dir_pwd" || return 1
  # set +o xtrace
  return $ec
}

recompile-o2() { recompile "O2" "$1" "$2"; }
recompile-o2p() { recompile "O2Physics" "$1" "$2"; }

# Find the workflow that produces a given table.
# Limited functionality. Use find_dependencies.py for full search.
find-o2-table-producer() {
  # Check that we are inside the O2 or the O2Physics directory.
  [[ "$PWD/" != *"/O2"*"/"* ]] && { echo "You must be inside the O2 or the O2Physics directory."; return 1; }
  [ ! "$1" ] && { echo "Provide a table name."; return 1; }
  # Find files that produce the table.
  table="$1"
  echo "Table $table is produced in:"
  files=$(grep -r -i --include="*.cxx" "<aod::$table>" | grep -E 'Produces|Spawns' | cut -d: -f1 | sort -u)
  for f in $files; do
    # Extract the workflow name from the CMakeLists.txt in the same directory.
    wf=$(grep -B 1 "$(basename "$f")" "$(dirname "$f")/CMakeLists.txt" | head -n 1 | cut -d\( -f2)
    echo "$wf in $f"
  done
}

debug-o2-compile() {
  [ "$1" ] || { echo "Provide a log file"; return 1; }
  grep -n -e "FAILED:" -e "error:" -e "warning:" "$1"
}

debug-o2-run() {
  [ "$1" ] || { echo "Provide a log file"; return 1; }
  grep -n -e "\\[ERROR\\]" -e "\\[FATAL\\]" -e "segmentation" -e "Segmentation" -e "SEGMENTATION" -e "command not found" -e "Program crashed" -e "Error:" -e "Error in " -e "\\[WARN\\]" -e "Warning in " "$1"
}
