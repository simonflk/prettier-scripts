#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_dir=$(readlink -f $script_dir/..)
if [ -f $project_dir/.env ]; then
  source $project_dir/.env;
fi

echo -e "\n\n• checking working directory"
if git st --porcelain | grep .; then
    RESET="\033[0m"
    BOLD="\033[1m"
    RED="\033[31m"
    echo -e "\n⚠  $BOLD$RED You have staged or unstaged changes$RESET\n"
    echo Please start with a clean slate before proceeding.
    echo '(e.g. `git stash --include-untracked`)'
    exit 1
fi

echo -e "\n\n• getting latest 'master'"
git checkout master
git pull origin master

echo -e "\n\n• installing prettier"
npm i -DE prettier@latest
version=$(node -p "require('prettier/package.json').version")

if git st --porcelain; then
    git commit --all --message="⬆️ upgrade prettier to version $version"
fi
git tag pre-prettier

echo -e "\n\n• formatting codebase"
$script_dir/prettify-all.sh
git diff --shortstat
echo '✨ formatted `master` branch. Test everything and then run `finish_upgrade.sh` when happy'
