#!/bin/bash

if [ ! -d "$lede_path/package/oaf" ]; then
  mkdir $lede_path/package/oaf
fi

pushd $lede_path/package/oaf

if [ ! -d "$lede_path/package/oaf/.git" ]; then
  git clone https://github.com/destan19/OpenAppFilter.git .
else
  git pull origin master
fi

# pushd $lede_path
# make menuconfig
# popd

popd