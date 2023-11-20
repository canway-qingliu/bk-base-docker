# 执行打包脚本
sh package.sh

# 生成流水号
base_version="1.0."
version_file="build_version.txt"
default_version=0
if [ -f "$version_file" ]; then
    serial_no=$(cat "$version_file")
    # 版本号+1
    ((serial_no++))
    # 写入文件
    echo "$serial_no" > "$version_file"
    echo "写入版本号成功: $serial_no"
else
    serial_no=$default_version
    # 版本号+1
    ((serial_no++))
    # 写入文件
    echo "$serial_no" > "$version_file"
    echo "写入版本号成功: $serial_no"
fi
echo "版本号: $serial_no"


# 模块、运行平台、构建号
SUBMODULE=jobnavi
RUN_VERSION=ee
BUILD_NO=${serial_no}
WORKSPACE=$(pwd)

bkbase_docker_repository_domain=docker.paas3-dev.bktencent.com

# 解压移动源码文件
#cd dist
tar -xzf *.tgz
echo '解压tag包成功'


VERSION=3.10.0

# 镜像编译
docker buildx build --platform linux/amd64  . -t "bkbase-${SUBMODULE}:${VERSION}-${BUILD_NO}"
echo 'docker镜像构建成功'

# push镜像到制品仓库
echo "镜像名称=bkbase-${SUBMODULE}api:${VERSION}-${BUILD_NO}"
docker_version=${VERSION}-${BUILD_NO}
echo "docker tag 版本号 ${docker_version}"
docker tag "bkbase-${SUBMODULE}:${VERSION}-${BUILD_NO}" $bkbase_docker_repository_domain/bkbase/bkbase-docker/bkbase-${SUBMODULE}:$docker_version

docker push $bkbase_docker_repository_domain/bkbase/bkbase-docker/bkbase-${SUBMODULE}api:$docker_version

# 清理中间产物
# rm -rf ./bkdata
# echo '清理bkdata成功'
# rm -rf ./code
# rm -rf *.tgz
# echo '清理tgz包成功'
#rm -rf ./support-files
#rm -rf ./Dockerfile