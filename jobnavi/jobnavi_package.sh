cd ${WORKSPACE}/code
JOBNAVI_ROOT=${WORKSPACE}/code/src/dataflow/jobnavi
# 如果是企业版，加入证书验证模块
echo ${RELEASE_ENV}
cd ${JOBNAVI_ROOT}
echo "workspace" `pwd`
if [ ${RELEASE_ENV} = "ee" ]; then
    echo "spark_sql:jobnavi-sparksql-adaptor
one_time_sql:jobnavi-sparksql-adaptor
stream:jobnavi-flink-adaptor
stream-code-flink-1.10.1:jobnavi-flink-adaptor
sparkstreaming:jobnavi-sparkstreaming-adaptor
command:jobnavi-cmd-adaptor
workflow:jobnavi-workflow" > adaptors.txt
    echo "use license main"
    cd ${JOBNAVI_ROOT}/jobnavi-scheduler/src/main/java/com/tencent/bk/base/dataflow/jobnavi/scheduler || exit 1
    rm -f JobNaviScheduler.java
    mv LicenseJobNaviScheduler.java JobNaviScheduler.java
    sed -i "s/LicenseJobNaviScheduler/JobNaviScheduler/g" JobNaviScheduler.java

    cd ${JOBNAVI_ROOT}/jobnavi-runner/src/main/java/com/tencent/bk/base/dataflow/jobnavi/runner || exit 1
    rm -f JobNaviRunner.java
    mv LicenseJobNaviRunner.java JobNaviRunner.java
    sed -i "s/LicenseJobNaviRunner/JobNaviRunner/g" JobNaviRunner.java
    
    cd ${JOBNAVI_ROOT}
fi
# 编译&预打包
mvn clean package -Dmaven.test.skip=true
PACKAGE_ROOT=$JOBNAVI_ROOT/bkdata
echo "JOBNAVI_ROOT:$JOBNAVI_ROOT"
mkdir -p $PACKAGE_ROOT
# jobnavischeduler
cd $PACKAGE_ROOT
mkdir -p jobnavischeduler/share/log-aggregation/lib
cd jobnavischeduler
mkdir bin lib
cd $JOBNAVI_ROOT
/bin/cp -f jobnavi-scheduler/target/jobnavi-scheduler-0.4.0-SNAPSHOT.jar $PACKAGE_ROOT/jobnavischeduler/lib
/bin/cp -f jobnavi-scheduler/target/dependency/* $PACKAGE_ROOT/jobnavischeduler/lib
/bin/cp -f jobnavi-log-aggregation/target/jobnavi-log-aggregation-0.4.0-SNAPSHOT.jar $PACKAGE_ROOT/jobnavischeduler/share/log-aggregation/lib
/bin/cp -f jobnavi-log-aggregation/target/dependency/* $PACKAGE_ROOT/jobnavischeduler/share/log-aggregation/lib
/bin/cp -f jobnavi-scheduler/src/main/bin/* $PACKAGE_ROOT/jobnavischeduler/bin
/bin/cp -f project_scheduler.yml $PACKAGE_ROOT/jobnavischeduler/project.yml
chmod 755 $PACKAGE_ROOT/jobnavischeduler/bin/*.sh

# jobnavirunner
cd $PACKAGE_ROOT
mkdir -p jobnavirunner/share/log-aggregation/lib
cd jobnavirunner
mkdir bin lib env adaptor tool
cd $JOBNAVI_ROOT
/bin/cp -f jobnavi-runner/target/jobnavi-runner-0.4.0-SNAPSHOT.jar $PACKAGE_ROOT/jobnavirunner/lib
/bin/cp -f jobnavi-api/target/jobnavi-api-0.4.0-SNAPSHOT.jar $PACKAGE_ROOT/jobnavirunner/lib
# jobnavirunner python api
/bin/cp -rf jobnavi-rpc/src/main/python/* jobnavi-api-python/jobnavi
mkdir -p $PACKAGE_ROOT/jobnavirunner/lib/jobnavi-api-python
/bin/cp -f jobnavi-api-python/requirements.txt $PACKAGE_ROOT/jobnavirunner/lib/jobnavi-api-python
/bin/cp -f jobnavi-api-python/task_launcher.py $PACKAGE_ROOT/jobnavirunner/lib/jobnavi-api-python
/bin/cp -rf jobnavi-api-python/jobnavi $PACKAGE_ROOT/jobnavirunner/lib/jobnavi-api-python
# jobnavirunner log aggregation
/bin/cp -f jobnavi-log-aggregation/target/jobnavi-log-aggregation-0.4.0-SNAPSHOT.jar $PACKAGE_ROOT/jobnavirunner/share/log-aggregation/lib
/bin/cp -f jobnavi-log-aggregation/target/dependency/* $PACKAGE_ROOT/jobnavirunner/share/log-aggregation/lib
/bin/cp -f jobnavi-runner/src/main/bin/* $PACKAGE_ROOT/jobnavirunner/bin
/bin/cp -f project_runner.yml $PACKAGE_ROOT/jobnavirunner/project.yml
chmod 755 $PACKAGE_ROOT/jobnavirunner/bin/*.sh

# task adaptors
cd $PACKAGE_ROOT
for adaptor in `cat $JOBNAVI_ROOT/adaptors.txt`
do
    read -r type_id module <<< "$(echo "$adaptor"|awk -F':' '{print $1, $2}')"
    echo "Type ID:$type_id -> module:$module"
    echo "Module directory:$JOBNAVI_ROOT/$module"
    if [ -d "$JOBNAVI_ROOT/$module" ]
    then
        mkdir -p jobnavirunner/adaptor/$type_id/tags/stable
        /bin/cp $JOBNAVI_ROOT/$module/target/jobnavi*.jar jobnavirunner/adaptor/$type_id/tags/stable/
    fi
    # copy adaptor dependencies
    if [ -d "$JOBNAVI_ROOT/$module/target/dependency" ]
    then
        mkdir jobnavirunner/adaptor/$type_id/tags/stable/lib
        /bin/cp $JOBNAVI_ROOT/$module/target/dependency/* jobnavirunner/adaptor/$type_id/tags/stable/lib
    fi
    # copy adaptor scripts
    if [ -d "$JOBNAVI_ROOT/$module/src/main/bin" ]
    then
        /bin/cp $JOBNAVI_ROOT/$module/src/main/bin jobnavirunner/adaptor/$type_id/tags/stable/ -r
    fi
done
chmod 755 jobnavirunner/adaptor/*/tags/stable/bin/*.sh

# package
cd $JOBNAVI_ROOT
if [ -f jobnavi.tar.gz ]
then
    mv jobnavi.tar.gz jobnavi.tar.gz.bak
fi
tar -czf jobnavi.tar.gz bkdata
mv jobnavi.tar.gz jobnavi.tgz
/bin/cp ${WORKSPACE}/code/src/dataflow/jobnavi/jobnavi.tgz ${WORKSPACE}/code/result_package

# hdfs-tool
cd ${WORKSPACE}/code
BUILD_ROOT=${WORKSPACE}/code/src/dataflow/hdfs-tools

cd ${WORKSPACE}/code/src/dataflow/jobnavi/
mvn clean install -DskipTests -pl jobnavi-api -am

cd ${BUILD_ROOT}
mvn clean package -Dmaven.test.skip=true
cd target/
mkdir -p lib
/bin/cp dependency/* lib/
tar -czf hdfs-tools-lib.tgz lib/
/bin/cp ${WORKSPACE}/code/src/dataflow/hdfs-tools/target/hdfs-tools-lib.tgz hdfs-tools-1.0.jar ${WORKSPACE}/code/result_package

# batch-common
cd ${WORKSPACE}/code/src/datahub/datalake/java
sed -i 's/<version>5.0.0<\/version>/<version>4.0.1<\/version>/g' base/pom.xml
sed -i 's/<version>5.0.0<\/version>/<version>4.0.1<\/version>/g' spark/pom.xml
sed -i 's/<version>5.0.0<\/version>/<version>4.0.1<\/version>/g' pom.xml
mvn clean install -DskipTests -pl base -am
sed -i 's/<version>4.0.1<\/version>/<version>4.0.0-SNAPSHOT<\/version>/g' pom.xml
sed -i 's/<version>4.0.1<\/version>/<version>4.0.0-SNAPSHOT<\/version>/g' base/pom.xml
sed -i 's/<version>4.0.1<\/version>/<version>4.0.0-SNAPSHOT<\/version>/g' spark/pom.xml
mvn clean install -DskipTests -pl spark -am

cd ${WORKSPACE}/code/src/datahub/cache
mvn clean install -DskipTests -pl ignite-plugin -am
sed -i 's/<version>4.0.0<\/version>/<version>4.0.0-SNAPSHOT<\/version>/g' pom.xml
sed -i 's/<version>4.0.0<\/version>/<version>4.0.0-SNAPSHOT<\/version>/g' base/pom.xml
sed -i 's/<version>4.0.0<\/version>/<version>4.0.0-SNAPSHOT<\/version>/g' ignite-plugin/pom.xml
sed -i 's/<version>4.0.0<\/version>/<version>4.0.0-SNAPSHOT<\/version>/g' spark/pom.xml
mvn clean install -DskipTests -pl spark -am

cd ${WORKSPACE}/code/src/dataflow/unified-computing
mvn clean scala:compile scala:testCompile package -pl batch/batch-common -am -Ppyspark-2.4.7 -DskipTests
mkdir ${WORKSPACE}/batch
/bin/cp ${WORKSPACE}/code/src/dataflow/unified-computing/batch/batch-common/target/batch-common-0.1.0-jar-with-dependencies.jar ${WORKSPACE}/batch

# batch sql
cd ${WORKSPACE}/code/src/dataflow/unified-computing
mvn clean scala:compile scala:testCompile package -pl batch/batch-sql -am -DskipTests
/bin/cp ${WORKSPACE}/code/src/dataflow/unified-computing/batch/batch-sql/target/batch-sql-0.1.0-jar-with-dependencies.jar ${WORKSPACE}/batch

# batch-one-time-sql
cd ${WORKSPACE}/code/src/dataflow/unified-computing
mvn clean scala:compile scala:testCompile package -pl batch/batch-one-time-sql -am -DskipTests
/bin/cp ${WORKSPACE}/code/src/dataflow/unified-computing/batch/batch-one-time-sql/target/batch-one-time-sql-0.1.0-jar-with-dependencies.jar ${WORKSPACE}/batch

# batch_python_code
cd ${WORKSPACE}/code/src/dataflow/unified-computing/python
zip -r batch_python_code.zip ./*
/bin/cp ${WORKSPACE}/code/src/dataflow/unified-computing/python/batch_python_code.zip ${WORKSPACE}/batch

# 构件目录修正
cd ${WORKSPACE}
#构建batch_sql
mkdir ${WORKSPACE}/batch_sql
cd ${WORKSPACE}/batch_sql
batch_sql_type_id=spark_sql
batch_sql_env=spark_2.4.7_sql
mkdir -p adaptor/$batch_sql_type_id/tags/stable
mv ${WORKSPACE}/batch/batch-sql*.jar ./adaptor/$batch_sql_type_id/tags/stable
mkdir -p env/$batch_sql_env
mv ${WORKSPACE}/code/lib/$batch_sql_env/* ./env/$batch_sql_env
tar -czf $batch_sql_type_id.tgz adaptor env
mv $batch_sql_type_id.tgz ${WORKSPACE}/code/result_package
#构建batch_one_time_sql
mkdir ${WORKSPACE}/batch_one_time_sql
cd ${WORKSPACE}/batch_one_time_sql
batch_one_time_sql_type_id=one_time_sql
batch_one_time_sql_env=spark_2.4.7_one_time_sql
mkdir -p adaptor/$batch_one_time_sql_type_id/tags/stable
mv ${WORKSPACE}/batch/batch-one-time-sql*.jar ./adaptor/$batch_one_time_sql_type_id/tags/stable
mkdir -p env/$batch_one_time_sql_env
mv ${WORKSPACE}/code/lib/$batch_one_time_sql_env/* ./env/$batch_one_time_sql_env
tar -czf $batch_one_time_sql_type_id.tgz adaptor env
mv $batch_one_time_sql_type_id.tgz ${WORKSPACE}/code/result_package
#构建batch_python_code
mkdir ${WORKSPACE}/batch_python_code
cd ${WORKSPACE}/batch_python_code
batch_python_code_type_id=spark_python_code
batch_python_code_env=spark_2.4.7_python_code
mkdir -p adaptor/$batch_python_code_type_id/tags/stable
unzip ${WORKSPACE}/batch/batch_python_code.zip -d ./adaptor/$batch_python_code_type_id/tags/stable
mkdir -p env/$batch_python_code_env
mv ${WORKSPACE}/code/lib/$batch_python_code_env/* ./env/$batch_python_code_env
mv ${WORKSPACE}/batch/batch-common*.jar ./env/$batch_python_code_env/
tar -czf $batch_python_code_type_id.tgz adaptor env
mv $batch_python_code_type_id.tgz ${WORKSPACE}/code/result_package


# session_server
session_server_type_id=spark_interactive_python_server
session_server_env=spark_2.4.7_interactive_python_server
env=bkdata/jobnavirunner/env
cd ${WORKSPACE}
mkdir -p ${WORKSPACE}/session_server
cd ${WORKSPACE}/session_server
mkdir -p adaptor/$session_server_type_id/tags/stable
/bin/cp ${WORKSPACE}/code/lib/livy-server-adaptor*.jar ./adaptor/$session_server_type_id/tags/stable
mkdir -p env/$session_server_env
unzip ${WORKSPACE}/code/lib/apache-livy-0.7.0-incubating-bin.zip -d ./env/$session_server_env
mv ./env/$session_server_env/apache-livy-0.7.0-incubating-bin/* ./env/$session_server_env
rm -rf ./env/$session_server_env/apache-livy-0.7.0-incubating-bin
/bin/cp ${WORKSPACE}/code/lib/livy_python_code.zip ./env/$session_server_env
mv ${WORKSPACE}/code/lib/$session_server_env/* ./env/$session_server_env
# 把构件放到对应的目录
tar -czf $session_server_type_id.tgz adaptor env
mv $session_server_type_id.tgz ${WORKSPACE}/code/result_package


# stream
mkdir -p ${WORKSPACE}/stream_build_file_dir
# flink-streaming
cd ${WORKSPACE}/code/src/datahub/databus
mvn clean install -Drevision=4.0.0 -pl databus-commons -am -Dmaven.test.skip=true -Dcheckstyle.skip=true
cd ${WORKSPACE}/code/src/datahub/cache
mvn clean install -DskipTests -pl base -am
cd ${WORKSPACE}/code/src/dataflow/unified-computing
mvn clean scala:compile package -pl stream/flink-streaming -am -Dmaven.test.skip=true
/bin/cp ${WORKSPACE}/code/src/dataflow/unified-computing/stream/flink-streaming/target/master-*.jar ${WORKSPACE}/stream_build_file_dir

# flink-code
cd ${WORKSPACE}/code/src/dataflow/unified-computing
mvn clean package -pl stream/flink-code -Pflink-code -am -Dmaven.test.skip=true
/bin/cp ${WORKSPACE}/code/src/dataflow/unified-computing/stream/flink-code/target/master_code_java-*.jar ${WORKSPACE}/stream_build_file_dir

# spark-streaming
cd ${WORKSPACE}/code/src/dataflow/unified-computing/python
zip -r master_code_python-0.0.1.zip bkbase
/bin/cp ${WORKSPACE}/code/src/dataflow/unified-computing/python/master_code_python-0.0.1.zip ${WORKSPACE}/stream_build_file_dir

# 构件目录修正
cd ${WORKSPACE}/stream_build_file_dir
# 0-准备env环境目录
TYPE_ID_FLINK_STREAMING=stream
TYPE_ID_FLINK_CODE=stream-code-flink-1.10.1
TYPE_ID_SPARK_STRUCTURED_STREAMING=sparkstreaming
FLINK_ENV_1_7_1=flink-1.7.2
FLINK_ENV_1_10_1=flink-1.10.1
mkdir -p env/${FLINK_ENV_1_7_1}/lib
mkdir -p env/${FLINK_ENV_1_7_1}/conf
/bin/cp ${WORKSPACE}/code/lib/flink-1.7.2/lib/*.jar            env/${FLINK_ENV_1_7_1}/lib/
/bin/cp ${WORKSPACE}/code/lib/flink-1.7.2/conf/*.properties    env/${FLINK_ENV_1_7_1}/conf/
/bin/cp ${WORKSPACE}/code/lib/flink-1.7.2/conf/zoo.cfg         env/${FLINK_ENV_1_7_1}/conf/

mkdir -p env/${FLINK_ENV_1_10_1}/lib
mkdir -p env/${FLINK_ENV_1_10_1}/conf
mkdir -p env/${FLINK_ENV_1_10_1}/bin
/bin/cp ${WORKSPACE}/code/lib/flink-1.10.1/lib/*.jar            env/${FLINK_ENV_1_10_1}/lib/
/bin/cp ${WORKSPACE}/code/lib/flink-1.10.1/conf/*.properties    env/${FLINK_ENV_1_10_1}/conf/
/bin/cp ${WORKSPACE}/code/lib/flink-1.10.1/conf/zoo.cfg         env/${FLINK_ENV_1_10_1}/conf/
/bin/cp ${WORKSPACE}/code/lib/flink-1.10.1/bin/*                env/${FLINK_ENV_1_10_1}/bin/
chmod +x env/${FLINK_ENV_1_10_1}/bin/*.sh

mkdir -p env/spark_2.4.7_spark_structured_streaming/
/bin/cp -r ${WORKSPACE}/code/lib/spark_2.4.7_spark_structured_streaming/* env/spark_2.4.7_spark_structured_streaming/
#----------------------------------------

# 1-准备flink streaming
mkdir -p adaptor/${TYPE_ID_FLINK_STREAMING}/tags/stable/job
mkdir -p adaptor/${TYPE_ID_FLINK_STREAMING}/tags/stable/lib
/bin/cp ./master-0.0.4.jar adaptor/${TYPE_ID_FLINK_STREAMING}/tags/stable/job/
/bin/cp ${WORKSPACE}/code/lib/flink_streaming/*.jar adaptor/${TYPE_ID_FLINK_STREAMING}/tags/stable/lib/
#----------------------------------------

# 2-准备flink code
mkdir -p adaptor/${TYPE_ID_FLINK_CODE}/tags/stable/job
/bin/cp ./master_code_java-0.0.1.jar adaptor/${TYPE_ID_FLINK_CODE}/tags/stable/job/
#----------------------------------------

# 3-准备spark structured streaming
mkdir -p adaptor/${TYPE_ID_SPARK_STRUCTURED_STREAMING}/tags/stable/lib
/bin/cp ./master_code_python-0.0.1.zip adaptor/${TYPE_ID_SPARK_STRUCTURED_STREAMING}/tags/stable/
/bin/cp ${WORKSPACE}/code/lib/spark_structured_streaming/pyspark.zip           adaptor/${TYPE_ID_SPARK_STRUCTURED_STREAMING}/tags/stable/
/bin/cp ${WORKSPACE}/code/lib/spark_structured_streaming/py4j-0.10.7-src.zip   adaptor/${TYPE_ID_SPARK_STRUCTURED_STREAMING}/tags/stable/
/bin/cp ${WORKSPACE}/code/lib/spark_structured_streaming/lib/*.jar             adaptor/${TYPE_ID_SPARK_STRUCTURED_STREAMING}/tags/stable/lib/
/bin/cp ${WORKSPACE}/code/lib/spark_structured_streaming/spark-2.4.7-bin-hadoop2.6.zip                adaptor/${TYPE_ID_SPARK_STRUCTURED_STREAMING}/tags/stable/
/bin/cp ${WORKSPACE}/code/lib/spark_structured_streaming/structured-streaming-extend-libs-2.4.7.jar   adaptor/${TYPE_ID_SPARK_STRUCTURED_STREAMING}/tags/stable/
#----------------------------------------

# 把构件放到对应的目录
tar -czf stream.tgz adaptor env
mv stream.tgz ${WORKSPACE}/code/result_package

# yarn-service
cd ${WORKSPACE}/code/src/dataflow/yarn-service
mvn clean package -DskipTests
cd target
TYPE_ID_YARN_SERVICE=yarn-service
type_id=${TYPE_ID_YARN_SERVICE}
mkdir -p ./adaptor/$type_id/tags/stable
mv yarn-service-*.jar adaptor/$type_id/tags/stable/yarn-service.jar
tar -czf $type_id.tgz adaptor
mv yarn-service.tgz ${WORKSPACE}/code/result_package

# ucapi-service
cd ${WORKSPACE}/code/src/dataflow/ucapi-service
mvn clean package -DskipTests
cd target
TYPE_ID_UCAPI_SERVICE=ucapi-service
type_id=${TYPE_ID_UCAPI_SERVICE}
mkdir -p ./adaptor/$type_id/tags/stable
mv ucapi-service-*.jar adaptor/$type_id/tags/stable/ucapi-service.jar
tar -czf $type_id.tgz adaptor
mv ucapi-service.tgz ${WORKSPACE}/code/result_package

# 整体打包
cd ${WORKSPACE}/code/result_package
mkdir uc
mkdir -p uc/uc
mkdir -p uc/hdfs-tools
mv jobnavi.tgz uc
mv one_time_sql.tgz uc/uc
mv spark_interactive_python_server.tgz uc/uc
mv spark_python_code.tgz uc/uc
mv spark_sql.tgz uc/uc
mv stream.tgz uc/uc
mv ucapi-service.tgz uc/uc
mv yarn-service.tgz uc/uc
mv hdfs-tools-1.0.jar uc/hdfs-tools
mv hdfs-tools-lib.tgz uc/hdfs-tools


cd ${WORKSPACE}/code/result_package/uc
# 解压预打包
tar -xzf jobnavi.tgz

# 放置hdfs工具
mkdir -p bkdata/jobnavirunner/tool/hdfs
/bin/cp ./hdfs-tools/*.jar bkdata/jobnavirunner/tool/hdfs -r
mkdir -p bkdata/jobnavirunner/adaptor/hdfs_backup/tags/stable
/bin/cp ./hdfs-tools/*.jar bkdata/jobnavirunner/adaptor/hdfs_backup/tags/stable
mkdir -p bkdata/jobnavirunner/adaptor/parquet_reader/tags/stable
/bin/cp ./hdfs-tools/*.jar bkdata/jobnavirunner/adaptor/parquet_reader/tags/stable
mkdir -p bkdata/jobnavirunner/env/parquet/
tar  -xzf ./hdfs-tools/hdfs-tools-lib.tgz -C bkdata/jobnavirunner/env/parquet/
mkdir -p bkdata/jobnavirunner/env/hdfs/
tar  -xzf ./hdfs-tools/hdfs-tools-lib.tgz -C bkdata/jobnavirunner/env/hdfs/

# 记录版本信息
VERSION=$(cat ${WORKSPACE}/code/VERSION)
VERSION=${VERSION}-${BuildNo}
echo $VERSION > ./VERSION
echo $VERSION > ./jobnavi.version
#记录时间
echo $(date) >>  ./jobnavi.version
/bin/cp VERSION bkdata/jobnavischeduler
/bin/cp VERSION bkdata/jobnavirunner
/bin/cp jobnavi.version bkdata/jobnavischeduler
/bin/cp jobnavi.version bkdata/jobnavirunner

# 放置support-files
/bin/cp -r ${WORKSPACE}/code/support-files/dataflow/jobnavi bkdata/support-files
chmod 755 bkdata/support-files/templates/*.sh
cd bkdata
echo "  version_type: ${RELEASE_ENV}" >> jobnavischeduler/project.yml
echo "  version_type: ${RELEASE_ENV}" >> jobnavirunner/project.yml

# 放置各模块预打包
cd ${WORKSPACE}/code/result_package/uc/bkdata/jobnavirunner
for package in `ls ../../uc/`
do
    if [ -f ../../uc/$package ]
    then
        tar -xzf ../../uc/$package
    fi
done

# 打整体包
cd ${WORKSPACE}/code/result_package/uc
tar -czf jobnavi_${RELEASE_ENV}_v${VERSION}.tgz bkdata
tar -tzf jobnavi_${RELEASE_ENV}_v${VERSION}.tgz bkdata
mv jobnavi_${RELEASE_ENV}_v${VERSION}.tgz ${WORKSPACE}/code/result_package
rm -rf ${WORKSPACE}/code/result_package/uc
