#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_dir=$(readlink -f $script_dir/..)
if [ -f $project_dir/.env ]; then
  source $project_dir/.env;
fi

branch=$(git symbolic-ref --short HEAD)
backup_tag=$branch-prettier-backup
merge_base_commit=$(git merge-base master $branch)
author=$(git log --format="%aN <%aE>" --max-count=1)

if [[ "$1" == "--auto" ]]; then
  PRETTIFY_AUTO=true
elif [[ "$1" == "--revert" ]]; then
  git reset --hard origin/$branch || true
  git tag -d $backup_tag 2>&1 || true
  exit;
fi

echo -e '\n\n➡️️  saving current state of `'$branch'` at `'$backup_tag'`'
git pull origin
git tag $backup_tag

echo -e '\n\n➡️️  squashing PR commits'
git reset --hard $merge_base_commit
git merge --squash $backup_tag
git commit --no-verify --no-edit --author="$author"

echo -e '\n\n➡️️  rebasing onto `'pre-prettier'`'
git rebase pre-prettier || {
  echo "conflicts during rebase for branch $branch"
  if [ "$PRETTIFY_AUTO" == "true" ]; then
    git rebase --abort
    git checkout --detach
    git clean -fd
    git branch -f $branch $backup_tag
    git co $branch
    git tag -d $backup_tag
  fi
  exit 1
}
npm install

echo -e '\n\n➡️️  formatting PR commit'
squashed_commit=$(git rev-parse HEAD)
git show --pretty="" --name-only | grep -E '\.(js|json)$' | grep -vE '(package(-lock)?|npm-shrinkwrap)'.json | xargs npx prettier --write
git commit --amend --all --no-verify --reuse-message=$squashed_commit
git rebase -X theirs post-prettier || {
  if [ "$PRETTIFY_AUTO" == "true" ]; then
    git rebase --abort
    git checkout --detach
    git clean -fd
    git branch -f $branch $backup_tag
    git co $branch
    git tag -d $backup_tag
  fi
  exit 1
}


if [ "$PRETTIFY_REMOTE" == "true" ]; then
  echo -e '\n\n➡️️  pushing `'$branch'`'
  git push -f origin $branch-prettier-backup $branch || true
fi
