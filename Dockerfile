FROM ubuntu:22.04
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
  apt-get install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
  bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
  git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev glib2.0 libgmp3-dev libltdl-dev \
  libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz \
  mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pyelftools \
  python3-setuptools libpython3-dev qemu-utils rsync scons squashfs-tools subversion swig texinfo \
  uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev clang && \
  apt-get install -y wget curl swig time nano tzdata && \
  touch /root/.bashrc && \
  ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata && \
  echo "alias time=/usr/bin/time" > /root/.bashrc && \
  rm -rf /var/lib/apt/lists/* && \
  git config --global http.sslverify false && \
  git config --global https.sslverify false

COPY root/ /

RUN \
  chmod +x /lede.sh && \
  touch /.config

WORKDIR /lede/

CMD [ "/lede.sh" ]
