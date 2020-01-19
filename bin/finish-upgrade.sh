#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_dir=$(readlink -f $script_dir/..)
if [ -f $project_dir/.env ]; then
  source $project_dir/.env;
fi

export PRETTIFY_REMOTE
while getopts ":w" opt; do
  case ${opt} in
    w ) # write
      PRETTIFY_REMOTE=true
      ;;
    \? )
      echo "Unrecognised option -${OPTARG}" >&2
      echo "Usage: finish-upgrade.sh [-w]" >&2
      exit 1;
      ;;
  esac
done

echo -e "\n\n• committing prettier code..."
GIT_COMMITTER_NAME=${GIT_COMMITTER_NAME:-prettier}
GIT_COMMITTER_EMAIL=${GIT_COMMITTER_EMAIL:-prettier@ontrackretail.co.uk}
git commit --author="${GIT_COMMITTER_NAME} <${GIT_COMMITTER_EMAIL}>" \
             --all --message="✨ prettier!" --no-verify

echo -e "\n\n• tagging"
git tag post-prettier

if [ "$PRETTIFY_REMOTE" == "true" ]; then
  echo -e "\n\n• pushing to 'master'"
  git push origin pre-prettier post-prettier master
fi

echo '✨ `master` is tagged.'
echo 'Press ENTER to upgrade all PR branches with `upgrade-branches.sh`'
read -s

$script_dir/upgrade-branches.sh
