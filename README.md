# prettier: scripts to upgrade a repo painlessly 🤞

This repo is a fork of the [code](https://github.com/flexport/prettier-scripts) described in the excellent article [Upgrading Prettier on a Large Codebase](https://flexport.engineering/upgrading-prettier-on-a-large-codebase-28d56c4de49e) By [Blake Johnson](https://github.com/bdj)

This article is recommended reading

## Summary of changes

See git commit comments for more details

* More logging
* Load config from `.env` file
* GITHUB_OWNER & GITHUB_REPO are automatically taken from origin url
* Don't push to origin by default
* New reset option to reset to origin
* Couple of bugs? squashed
* ...

## Installation

```bash
~dev/ $ npx degit github:simonflk/prettier-scripts # or: git clone <url>
~dev/ $ cd prettier-scripts
~dev/ $ cp .env.sample .env
~dev/ $ vi .env
```

## Configuration

Configuration comes from environment variables, and you can set these in a `.env` file placed in the same directory as this README.

You will find a `.env.sample` file that you can start with and customise to your liking.

You will need to get a [personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) from github, if you wish to fetch branch names for open pull requests using the `get-branches.sh` script.



## Usage

```bash
# 1. format master, but don't commit
~dev/my-project/ $ ../prettier-scripts/upgrade.sh

# 2. test, manual tweaks
# ...

# 3. finalise master & upgrade all PR branches
~dev/my-project/ $ ../prettier-scripts/finish-upgrade.sh

# 4. add timestamped tags for before/after upgrade
~dev/my-project/ $ ../prettier-scripts/cleanup.sh
```

## Scripts

These should be run from within the directory of the repository you wish to format

### `upgrade.sh [-i]`

* Optionally installs latest version of `prettier` (`-i` option)
* Tags newest commit `pre-prettier`
* Formats all the JS/JSON

After running this command, you should run tests, and manually verify that everything works.

### `finish-upgrade.sh [-w]`

Run this on `master` after running `upgrade.sh` and verifying that the result looks ok

* Commits the reformatted code to master
* Tags this commit `post-prettier`
* Optionally pushes to master (with `-w` option)
* Starts process of formatting PR branches (with `upgrade-branches.sh`)

### `upgrade-branches.sh [-w]`

* Reformats branches which are for open pull requests
* Invokes `upgrade-branch.sh` for each branch
* Logs progress to `logs/` dir next to where these scripts run from
* Outputs summary of successes/failures at the end

### `upgrade-branch.sh [-a] [-r] [-w]`

* Formats the code in the current branch
* PR commits are squashed into a single commit
* with `-a` option, repo will be cleaned up in the event of failure/conflicts
* with `-r` option, repo will be reset to `origin/$branch`
* with `-w` option, updated branch will be force-pushed, and the _pre-upgrade_ commit will be tagged `${branch}-prettier-backup`

### `cleanup.sh`

Run this after `cleanup.sh` and pushing to `origin`

* Adds timestamped `pre-prettier-${timestamp}` and `post-prettier-${timestamp}` tags, and removes the non-timestamped ones

Also:

* `get-branches.sh`: outputs the branch name for each pull request in repo
* `prettify-all.sh`: commands that are run against `master` to format & test the code
* `revert-branches.sh`: tries to clean up after `upgrade-branches and restore to pre-prettier state. _at this time, it only works if changes were not pushed to origin_

