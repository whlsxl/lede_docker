# lede 编译环境

利用docker一键编译[Lean源](https://github.com/coolsnowwolf/lede)。适用于有闲置服务器资源，随时可以自行编译。

**编译需要外网环境**

## 挂载文件 VOLUME

* `/lede/`：编译的工作路径，lede仓库会clone到这个目录。挂载出来可以保留没修改部分的编译。
* `/.config`：make的配置文件，通过`make menuconfig`生成。
* `/diy.sh`：自定义仓库下载脚本，有时我们要向LEDE添加我们自己的插件。注意要考虑目录存在的情况。
* `/lede/bin`：编译生成的产品目录。

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
  -v $(pwd)/bin:/lede/bin \
  whlsxl/lede:latest
```

## 自定义源码仓库

根目录`diy.sh`为自定义脚本示例。把脚本挂载到`/diy.sh`文件下，在下载完lede仓库后，自动执行。

注意要考虑仓库已经存在情况。

判断当前目录是不是git仓库，`git rev-parse --is-inside-work-tree > /dev/null 2>&1;`。

## 执行命令

### dirclean

如果项目编译时出错，清理编译文件
```
docker run --rm -it --name lede \
  -v $(pwd)/lede_new:/lede \
  -v $(pwd)/x86.config:/.config \
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
  -v $(pwd)/bin:/lede/bin \
  whlsxl/lede:latest
  make menuconfig
```

### 加快编译速度

默认执行的make是单线程的，出问题容易追踪。以下自动使用多线程编译 

```
docker run --rm -it --name lede \
  -v $(pwd)/lede_new:/lede \
  -v $(pwd)/x86.config:/.config \
  -v $(pwd)/bin:/lede/bin \
  whlsxl/lede:latest
  make V=s
```

## 配置文件

分享个我在软路由上用的配置文件，编译x86_64架构的镜像文件。[x86.config](https://github.com/whlsxl/lede_docker/blob/master/x86.config)，可以在这个基础上定制。

[diy.sh](https://github.com/whlsxl/lede_docker/blob/master/diy.sh)，为自定义脚本示例。
