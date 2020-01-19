#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_dir=$(readlink -f $script_dir/..)
log_dir="${project_dir}/logs"
log_file="${log_dir}/prettify-branches-$(date +%Y%m%d%H%M).log"
if [ -f $project_dir/.env ]; then
  source $project_dir/.env;
fi
current_branch=$(git symbolic-ref --short HEAD)

if [ ! -e $log_dir ]; then
  mkdir $log_dir
fi

export PRETTIFY_REMOTE
while getopts ":wn" opt; do
  case ${opt} in
    w ) # write
      PRETTIFY_REMOTE=true
      ;;
    \? )
      echo "Unrecognised option -${OPTARG}" >&2
      echo "Usage: upgrade-branches.sh [-w]" >&2
      exit 1;
      ;;
  esac
done

formatted=()
failed=()
for branch in $($script_dir/get-branches.sh); do
  echo -e '\n\n• upgrading `'$branch'`'
  git checkout $branch
  if $script_dir/upgrade-branch.sh -a; then
    formatted+=($branch)
    echo "[$(date)]: PASS $branch" >> $log_file
  else
    failed+=($branch)
    echo "[$(date)]: FAIL $branch" >> $log_file
  fi
done
git checkout $current_branch

echo 'Summary of results:'
if [ ${#formatted[@]} -ne 0 ]; then
    echo -e "\nFormatted:"
    for i in ${formatted[@]}; do echo "  ✨ $i"; done
fi
if [ ${#failed[@]} -ne 0 ]; then
  echo -e "\nFailed to reset:"
  for i in ${failed[@]}; do echo "  ⚠️  $i"; done
  exit 1
fi
