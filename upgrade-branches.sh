#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f $script_dir/.env ]; then
  source $script_dir/.env;
fi
current_branch=$(git symbolic-ref --short HEAD)
for branch in $@; do
  git checkout $branch
  $script_dir/upgrade-branch.sh || continue
done
git checkout $current_branch
