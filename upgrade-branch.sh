#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f $script_dir/.env ]; then
  source $script_dir/.env;
fi
branch=$(git symbolic-ref --short HEAD)
backup_tag=$branch-prettier-backup
merge_base_commit=$(git merge-base master $branch)
author=$(git log --format="%aN <%aE>" --max-count=1)
git pull origin
git tag $backup_tag
git reset --hard $merge_base_commit
git merge --squash $backup_tag
git commit --no-verify --no-edit --author="$author"
git rebase pre-prettier || {
  echo "conflicts during rebase for branch $branch"
  git rebase --abort
  git checkout --detach
  git branch -f $branch $backup_tag
  git tag -d $backup_tag
  exit 1
}
squashed_commit=$(git rev-parse HEAD)
npm install
git reset HEAD^
git diff --name-only | xargs npx prettier --write
git commit --all --no-verify --reuse-message=$squashed_commit
git rebase -X theirs post-prettier
if [ "$PRETTIFY_REMOTE" == "true" ]; then
  git push -f origin $branch-prettier-backup $branch || true
fi
