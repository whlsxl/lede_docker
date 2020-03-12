FROM ubuntu:18.04
LABEL maintainer="Hailong <whlsxl@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_UNSAFE_CONFIGURE=1

# ENV LANG en_US.utf8
# `/lede/` is lede repository location
# `/.config`
# lede make config file, generate after make menuconfig
VOLUME /lede/
# build img path
VOLUME /lede/bin

# /diy_respository.sh
# The script to diy lede respository

RUN \
  touch /etc/apt/sources.list && \
  dpkg --add-architecture i386 && \
  # sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3.5 \
      unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp \
      libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint \
      device-tree-compiler g++-multilib linux-libc-dev:i386 && \
  apt-get install -y wget curl time nano tzdata && \
  touch /root/.bashrc && \
  ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata && \
  echo "alias time=/usr/bin/time" > /root/.bashrc && \
  rm -rf /var/lib/apt/lists/*

COPY root/ /

RUN \
  chmod +x /lede.sh && \
  touch /.config

WORKDIR /lede/

CMD [ "/lede.sh" ]