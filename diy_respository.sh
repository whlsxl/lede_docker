#!/bin/bash

pushd $lede_path/package

if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  git pull origin master
else
  git clone https://github.com/destan19/OpenAppFilter.git oaf
fi
popd