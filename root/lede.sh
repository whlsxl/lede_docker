#!/bin/bash

diy_sh="/diy.sh"

lede_path="/lede"
lede_git="https://github.com/coolsnowwolf/lede"

cd $lede_path
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  git pull origin master
else
  git clone $lede_git tmp && mv tmp/.git . && rm -rf tmp && git reset --hard
fi

if [ -f ${lede_path}/.config ]; then
  echo "Warning: ${lede_path}/.config file exists. Removing it."
  rm ${lede_path}/.config
fi

cp /.config ${lede_path}/.config
if [ -f /feeds.conf.default ]; then
  mv ${lede_path}/feeds.conf.default ${lede_path}/feeds.conf.default.bak
  cp /feeds.conf.default ${lede_path}/feeds.conf.default
fi

$lede_path/scripts/feeds update -a 
$lede_path/scripts/feeds install -a

if [ -f "$diy_sh" ]; then
  echo "runing diy.sh ..."
  source $diy_sh
  echo "finish diy.sh"
fi

cd $lede_path
make download -j8

if [ -f /feeds.conf.default ]; then
  rm ${lede_path}/feeds.conf.default
  mv ${lede_path}/feeds.conf.default.bak ${lede_path}/feeds.conf.default
fi

if [ "$#" -gt 0 ]; then
  # 如果有参数，则执行传入的命令
  exec "$@"
else
  # 如果没有参数，则执行默认命令
  exec make V=s -j$(nproc)
fi