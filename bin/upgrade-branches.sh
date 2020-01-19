#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_dir=$(readlink -f $script_dir/..)
log_file="${project_dir}/logs/prettify-branches-$(date -I).log"
if [ -f $project_dir/.env ]; then
  source $project_dir/.env;
fi
current_branch=$(git symbolic-ref --short HEAD)

formatted=()
failed=()
for branch in $($script_dir/get-branches.sh); do
  echo -e '\n\n• upgrading `'$branch'`'
  git checkout $branch
  if $script_dir/upgrade-branch.sh --auto; then
    formatted+=($branch)
    echo "[$(date)]: PASS $branch" >> $log_file
  else
    failed+=($branch)
    echo "[$(date)]: FAIL $branch" >> $log_file
  fi
done
git checkout $current_branch

echo 'Summary of results:'
for i in ${formatted[@]}; do echo "✨ $i"; done
for i in ${failed[@]}; do echo "⚠️  $i"; done
