import subprocess

# 执行命令并获取输出

docker_image_name = "bkbase-metaapi"
# 执行命令并获取返回值
command = "docker images --format '{{.Repository}}|{{.ID}}|{{.Tag}}' | grep " + docker_image_name
output = subprocess.check_output(command, shell=True)
docker_images = str(output.decode()).split("\n")
docker_images_version_ids = set()
docker_images_id_ids = {}
for item in docker_images:
    if item == "0":
        continue
    row = item.split("|")
    if row[0] == docker_image_name:
        version = row[2].split("-")[1]
        image_id = row[1]
        docker_images_version_ids.add(version)
        docker_images_id_ids[version] = image_id
max_version = max(docker_images_version_ids)
print("当前最大版本号={0}".format(max_version))
max_image_id = docker_images_id_ids[max_version]
print("当前最大镜像版本id={0}".format(max_image_id))
docker_tag_cmd = "docker tag {0} docker.paas3-dev.bktencent.com/bkbase/bkbase-docker/".format(max_image_id) + docker_image_name +":bk_dev_1.0.{0} ".format(max_version)
docker_tag_cmd_output = subprocess.check_output(docker_tag_cmd, shell=True)
print("上传镜像到制品仓库")
docker_push_cmd = "docker push docker.paas3-dev.bktencent.com/bkbase/bkbase-docker/" + docker_image_name +":bk_dev_1.0.{0}".format(max_version)
docker_push_cmd_output = subprocess.check_output(docker_push_cmd, shell=True)
print("---上传成功---")
