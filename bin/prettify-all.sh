#!/bin/bash
set -e
git ls-files '*.js' '*.jsx' '*.json' | grep -vE '(package(-lock)?|npm-shrinkwrap)'.json | xargs -n 100 npx prettier --write
#npx jest -u
