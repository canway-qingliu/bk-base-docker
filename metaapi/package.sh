releaseCodePath=/Users/liuqing/IdeaProjects/release/bk-base
devCodePath=/Users/liuqing/IdeaProjects/prod/bk-base
package_path=/Users/liuqing/opt/docker/bk-base-docker/metaapi
docker run --rm --name meta_api -e WORKSPACE="/bkdata" -e submodule_name="meta" -e pizza_py_version="upizza" -e RUN_VERSION="ee" -e BuildNo="710" -v $package_path:/bkdata/code/result_package -v $releaseCodePath:/bkdata/code -itd bk-base-common:v1 /bin/bash
container_id=`docker ps | grep meta_api | awk '{print $1}'`
docker cp /Users/liuqing/opt/bkbase_ee/bin/api_package.sh ${container_id}:/bkdata
# 将本地代码复制到容器中
docker exec -it ${container_id} /bin/bash -c '/bkdata/api_package.sh'
docker stop ${container_id}