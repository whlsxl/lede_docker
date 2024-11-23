#!/bin/bash

diy_sh="/diy.sh"

lede_path="/lede"
lede_git="https://github.com/coolsnowwolf/lede"
v_immortalwrt_git="https://github.com/VIKINGYFY/immortalwrt.git" 

if [ -n "$LEDE_GIT_PATH" ]; then
    git_url="$LEDE_GIT_PATH"
else
    git_url="$lede_git"
fi
echo "LEDE git path: $git_url"

if [ -z "${LEDE_GIT_BRANCH}" ]; then
    LEDE_GIT_BRANCH="master"
fi

cd $lede_path
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  git fetch origin
  git reset --hard origin/$LEDE_GIT_BRANCH
else
  tmp_path=${lede_path}/tmp
  if [ ! -d ${tmp_path} ]; then
    rm -rf ${tmp_path}
  fi
  git clone --depth 1 $git_url ${tmp_path}
  # git clone --depth 1 $git_url .
  shopt -s dotglob  && mv ${tmp_path}/* .  && shopt -u dotglob  && rm -rf ${tmp_path}
  git reset --hard
  git checkout $LEDE_GIT_BRANCH
fi

if [ -f ${lede_path}/.config ]; then
  echo "Warning: ${lede_path}/.config file exists. Removing it."
  rm ${lede_path}/.config
fi

ln -s /.config ${lede_path}/.config
if [ -f /feeds.conf.default ]; then
  mv ${lede_path}/feeds.conf.default ${lede_path}/feeds.conf.default.bak
  cp /feeds.conf.default ${lede_path}/feeds.conf.default
fi

if [ -f /bin ]; then
  ln /bin ${lede_path}/bin
fi

$lede_path/scripts/feeds update -a 
$lede_path/scripts/feeds install -a

if [ -f "$diy_sh" ]; then
  echo "runing diy.sh ..."
  source $diy_sh
  echo "finish diy.sh"
fi

cd $lede_path
make download -j$(nproc)

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