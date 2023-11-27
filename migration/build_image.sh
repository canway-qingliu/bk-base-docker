
rm -rf ./migration
cp -r  /Users/liuqing/IdeaProjects/release/bk-base/src/migration ./



version=1.0.6

docker build  --platform linux/amd64 . -t bkbase-migration:$version

export bkbase_docker_repository_domain=docker.paas3-dev.bktencent.com
docker tag bkbase-migration:$version $bkbase_docker_repository_domain/bkbase/bkbase-docker/bkbase-migration:$version

docker push $bkbase_docker_repository_domain/bkbase/bkbase-docker/bkbase-migration:$version
