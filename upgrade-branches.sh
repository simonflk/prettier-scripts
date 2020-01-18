#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f $script_dir/.env ]; then
  source $script_dir/.env;
fi
current_branch=$(git symbolic-ref --short HEAD)

formatted=()
failed=()
rm $script_dir/fails.log || true
for branch in $($script_dir/get-branches.sh); do
  echo -e '\n\n• upgrading `'$branch'`'
  git checkout $branch
  if $script_dir/upgrade-branch.sh --auto; then
    formatted+=($branch)
  else
    failed+=($branch)
    echo "[$(date)]: $branch" >> $script_dir/fails.log
  fi
done
git checkout $current_branch

echo 'Summary of results:'
for i in ${formatted[@]}; do echo "✨ $i"; done
for i in ${failed[@]}; do echo "⚠️  $i"; done
