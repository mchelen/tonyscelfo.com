#!/bin/bash
set -e
cd $(dirname ${BASH_SOURCE[0]})

if [ ! -d _submodules/jekyll_alias_generator/.git ]; then
  echo
  echo "Submodules aren't initialized."
  echo
  echo "Run this command once to initialze the jekyll alias submodule."
  echo "$ git submodule sync --init"
  exit 1
fi

jekyll build
rm _site/app.yaml
./_pagespeed.sh
