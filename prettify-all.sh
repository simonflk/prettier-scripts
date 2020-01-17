#!/bin/bash
set -e
git ls-files *.js *.jsx *.json | xargs -n 100 yarn prettier --write
yarn jest -u