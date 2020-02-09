#!/bin/bash

diy_sh="/diy_respository.sh"

lede_path="/lede"
lede_git="https://github.com/coolsnowwolf/lede"

cd $lede_path
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  git pull origin master
else
  git clone $lede_git tmp && mv tmp/.git . && rm -rf tmp && git reset --hard
fi

ln -s /.config ${lede_path}/.config
$lede_path/scripts/feeds update -a 
$lede_path/scripts/feeds install -a

if [ -f "$diy_sh" ]; then
  source $diy_sh
fi

cd $lede_path
make -j1 V=s
