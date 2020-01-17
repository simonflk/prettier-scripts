#!/bin/bash
set -e
git ls-files *.js *.jsx *.json | xargs -n 100 npx prettier --write
npx jest -u
