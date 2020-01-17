#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f $script_dir/.env ]; then
  source $script_dir/.env;
fi
git checkout master
git pull origin master
#npm i prettier@latest
version=$(node -p "require('prettier/package.json').version")
git commit --all --message="⬆️ upgrade prettier to version $version"
git tag pre-prettier
$script_dir/prettify-all.sh
