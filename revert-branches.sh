#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f $script_dir/.env ]; then
  source $script_dir/.env;
fi
current_branch=$(git symbolic-ref --short HEAD)

reverted=()
failed=()
for branch in $($script_dir/get-branches.sh); do
  echo -e '\n\n• reverting `'$branch'`'
  git checkout $branch
  if $script_dir/upgrade-branch.sh --revert; then
    reverted+=($branch)
  else
    failed+=($branch)
  fi
done
git checkout $current_branch

echo 'Summary of results:'
for i in ${reverted[@]}; do echo "↩️  $i"; done
for i in ${failed[@]}; do echo "⚠️  $i"; done
