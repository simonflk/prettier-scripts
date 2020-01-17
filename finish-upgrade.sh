#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f $script_dir/.env ]; then
  source $script_dir/.env;
fi
GIT_COMMITTER_NAME=${GIT_COMMITTER_NAME:-prettier}
GIT_COMMITTER_EMAIL=${GIT_COMMITTER_EMAIL:-prettier@ontrackretail.co.uk}
git commit --author="${GIT_COMMITTER_NAME} <${GIT_COMMITTER_EMAIL}>" \
             --all --message="✨ prettier!" --no-verify

git tag post-prettier
if [ "$PRETTIFY_REMOTE" == "true" ]; then
  git push origin pre-prettier post-prettier master
fi

$script_dir/get-branches.sh | xargs -n 100 $script_dir/upgrade-branches.sh
