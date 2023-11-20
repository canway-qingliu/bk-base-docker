# 1.容器启动

base_path=/root/bk-base/
repo_path=/opt/tools/apache-maven-3.8.4/repo

result_package_path=/root/target/jobnavi

docker run --rm --name jobnavi -e WORKSPACE="/bkdata" -e RELEASE_ENV="ee" -e BuildNo="137"  -v $base_path:/bkdata/code -v $result_package_path:/bkdata/code/result_package -v $repo_path:/root/.m2/repository -itd bk-base-common:v1 /bin/bash

# 2.拷贝脚本并执行
chmod +x jobnavi_package.sh
container_id=`docker ps | grep jobnavi | awk '{print $1}'`
docker cp settings.xml ${container_id}:/opt/maven/conf
docker cp jobnavi_package.sh ${container_id}:/bkdata
docker exec -d ${container_id} /bin/bash -c '/bkdata/jobnavi_package.sh'
# docker exec -d ${container_id} /bin/bash -c 'nohup /bkdata/jobnavi_package.sh > /bkdata/jobnavi.log 2>&1 &'
docker exec -it ${container_id} /bin/bash -c 'tail -f /bkdata/jobnavi.log'
docker stop ${container_id}