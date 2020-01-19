#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_dir=$(readlink -f $script_dir/..)
if [ -f $project_dir/.env ]; then
  source $project_dir/.env;
fi
timestamp=$(date +"%Y-%m-%d")
git tag pre-prettier-$timestamp pre-prettier
git tag post-prettier-$timestamp post-prettier
git push origin pre-prettier-$timestamp post-prettier-$timestamp
git tag -d pre-prettier post-prettier
if [ "$PRETTIFY_REMOTE" == "true" ]; then
  git push --delete origin pre-prettier post-prettier
  git tag | grep prettier-backup | tee >(xargs git tag -d > /dev/null 2>&1) | xargs git push --delete origin
fi


