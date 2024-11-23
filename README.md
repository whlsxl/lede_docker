# lede 编译环境

利用docker一键编译OpenWRT[Lede]。适用于有闲置服务器资源，随时可以自行编译。

**编译需要外网环境**

## 挂载文件 VOLUME

* `/lede/`：编译的工作路径，lede仓库会clone到这个目录。挂载出来可以保留没修改部分的编译。
* `/.config`：make的配置文件，通过`make menuconfig`生成。
* `/feeds.conf.default`：软件包源的配置文件。
* `/diy.sh`：自定义仓库下载脚本，有时我们要向LEDE添加我们自己的插件。注意要考虑目录存在的情况。
* `/lede/bin`：编译生成的产品目录。

## 环境变量定义

* `LEDE_GIT_PATH`: Lede 或 OpenWRT 的git地址, 支持[coolsnowwolf的Lede](https://github.com/coolsnowwolf/lede) 和支持高通cpu(如京东云AX1800)的[immortalwrt](https://github.com/VIKINGYFY/immortalwrt) 等
* `LEDE_GIT_BRANCH`: `LEDE_GIT_PATH` 源的分支,有些是`master`,有些是`main`

## 使用

简单使用

```
docker run \
  --rm \
  -it \
  -d \
  --name lede \
  -v [lede仓库存储位置]:/lede \
  -v [.config文件存储位置]:/.config \
  -v [feeds.conf.default文件存储位置]:/feeds.conf.default \
  -v [编译产品存储位置]:/lede/bin \
  whlsxl/lede:latest
```
* `--rm`：编译完成后，自动销毁`container`
* `-d`：后台运行，查看正在编译日志`docker logs -f lede`
* `-v`：挂载文件或目录
如果不挂载`/lede`目录，docker会自动挂载匿名卷，保存编译源码。

如果使用当前目录存储所有数据，直接产出编译产品。如果`.config`文件为空，运行docker期间会打开`make menuconfig`界面配置。

```
docker run --rm -it --name lede \
  -v $(pwd)/lede_new:/lede \
  -v $(pwd)/x86.config:/.config \
  -v $(pwd)/feeds.conf.default:/feeds.conf.default \
  -v $(pwd)/bin:/lede/bin \
  whlsxl/lede:latest
```

编译immortalwrt

生成配置文件

```
docker run \
  --rm \
  -it \
  --name lede \
  -e LEDE_GIT_PATH="https://github.com/VIKINGYFY/immortalwrt.git" \
  -e LEDE_GIT_BRANCH="main" \
  -v $(pwd)/lede.immortalwrt:/lede  \
  -v $(pwd)/immortalwrt.config:/.config \
  -v $(pwd)/bin.immortalwrt:/lede/bin \
  -v $(pwd)/feeds.conf.default.immortalwrt:/feeds.conf.default \
  whlsxl/lede:latest make menuconfig
```

开始编译

```
docker run \
  -d \
  --rm \
  -it \
  --name lede \
  -e LEDE_GIT_PATH="https://github.com/VIKINGYFY/immortalwrt.git" \
  -e LEDE_GIT_BRANCH="main" \
  -v $(pwd)/lede.immortalwrt:/lede  \
  -v $(pwd)/immortalwrt.config:/.config \
  -v $(pwd)/bin.immortalwrt:/lede/bin \
  -v $(pwd)/feeds.conf.default.immortalwrt:/feeds.conf.default \
  whlsxl/lede:latest make -j1 V=s
```

使用`make -j1 V=s` 可单线程编译,方便查看编译错误.

其中`feeds.conf.default.immortalwrt`内容参考,包含`luci-app-ssr-plus` 和 `luci-app-passwall`

```
src-git packages https://github.com/immortalwrt/packages.git
src-git luci https://github.com/immortalwrt/luci.git
src-git routing https://github.com/openwrt/routing.git
src-git telephony https://github.com/openwrt/telephony.git
src-git nss_packages https://github.com/qosmio/nss-packages.git
src-git sqm_scripts_nss https://github.com/qosmio/sqm-scripts-nss.git
#src-git-full video https://github.com/openwrt/video.git
#src-git-full targets https://github.com/openwrt/targets.git
#src-git-full oldpackages http://git.openwrt.org/packages.git
#src-link custom /usr/src/openwrt/custom-feed

src-git helloworld https://github.com/fw876/helloworld.git
src-git kenzo https://github.com/kenzok8/openwrt-packages
src-git small https://github.com/kenzok8/small

```


## 自定义源码仓库

根目录`diy.sh`为自定义脚本示例。把脚本挂载到`/diy.sh`文件下，在下载完lede仓库后，自动执行。

注意要考虑仓库已经存在情况.

判断当前目录是不是git仓库，`git rev-parse --is-inside-work-tree > /dev/null 2>&1;`。

## 执行命令

### dirclean

如果项目编译时出错，清理编译文件
```
docker run --rm -it --name lede \
  -v $(pwd)/lede_new:/lede \
  -v $(pwd)/x86.config:/.config \
  -v $(pwd)/feeds.conf.default:/feeds.conf.default \
  -v $(pwd)/bin:/lede/bin \
  whlsxl/lede:latest
  make dirclean
```
### make menuconfig

手动生成配置文件

```
docker run --rm -it --name lede \
  -v $(pwd)/lede_new:/lede \
  -v $(pwd)/x86.config:/.config \
  -v $(pwd)/feeds.conf.default:/feeds.conf.default \
  -v $(pwd)/bin:/lede/bin \
  whlsxl/lede:latest
  make menuconfig
```

### 编译查错

默认执行的make是多线程的，出问题不容易追踪。以下自动使用单线程编译,容易追踪出错原因.

```
docker run --rm -it --name lede \
  -v $(pwd)/lede_new:/lede \
  -v $(pwd)/x86.config:/.config \
  -v $(pwd)/feeds.conf.default:/feeds.conf.default \
  -v $(pwd)/bin:/lede/bin \
  whlsxl/lede:latest
  make V=s -j1
```

## 配置文件

分享个我在软路由上用的配置文件，编译x86_64架构的镜像文件。[x86.config](https://github.com/whlsxl/lede_docker/blob/master/x86.config)，可以在这个基础上定制。

[diy.sh](https://github.com/whlsxl/lede_docker/blob/master/diy.sh)，为自定义脚本示例。
