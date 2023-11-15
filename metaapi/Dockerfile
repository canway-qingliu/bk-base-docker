FROM python:3.6.9-slim-buster
USER root

RUN rm /etc/apt/sources.list && \
    echo "deb https://mirrors.cloud.tencent.com/debian buster main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.cloud.tencent.com/debian buster-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src https://mirrors.cloud.tencent.com/debian buster main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src https://mirrors.cloud.tencent.com/debian buster-updates main contrib non-free" >> /etc/apt/sources.list

RUN mkdir ~/.pip &&  printf '[global]\nindex-url = https://mirrors.tencent.com/pypi/simple/' > ~/.pip/pip.conf
RUN apt-get update && apt-get install -y gcc libsasl2-dev libsnappy-dev libmariadbclient-dev g++ telnet vim tar \
    net-tools curl busybox wget procps jq python3-dev default-libmysqlclient-dev build-essential unzip

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

WORKDIR /app/code

# init env
RUN cd /app/ && \
    python3 -m venv ./venv

COPY code/requirements.txt /app/code/
COPY support-files/pkgs /app/support-files/pkgs

# install packages
RUN cd /app/code && \
    . /app/venv/bin/activate &&  \
    pip install --upgrade pip &&  \
    pip install -r requirements.txt --find-links /app/support-files/pkgs/

# add java & jpy
RUN if [ $(cat /app/code/requirements.txt | grep jpy== | wc -l) = "1" ] ; then  \
    mkdir -p /opt  && \
    cd /opt  && \
    wget  -c https://mirrors.tencent.com/repository/generic/konajdk/8/0/9/linux-x86_64/b1/TencentKona8.0.9.b1_jdk_linux-x86_64_8u322.tar.gz && \
    tar xf TencentKona8.0.9.b1_jdk_linux-x86_64_8u322.tar.gz && \
    rm -f TencentKona8.0.9.b1_jdk_linux-x86_64_8u322.tar.gz; fi
ENV JAVA_HOME=/opt/TencentKona-8.0.9-322
ENV PATH=${JAVA_HOME}/bin:$PATH
ENV CLASSPATH=.:${JAVA_HOME}/lib
RUN if [ $(cat /app/code/requirements.txt | grep jpy== | wc -l) = "1" ] ; then  /app/venv/bin/python -m jpyutil ; fi

# move code
COPY code /app/code
COPY support-files /app/support-files

RUN mkdir -p /app/logs && \
    mv /app/code/bin/start.sh /app/code/start.sh && \
    mv /app/code/bin/start_celery.sh /app/code/start_celery.sh && \
    mv /app/code/bin/start_celery_beat.sh /app/code/start_celery_beat.sh && \
    mv /app/code/bin/celery_worker_inspect.sh /app/code/celery_worker_inspect.sh && \
    mv /app/code/bin/import_ms.sh /app/code/import_ms.sh

# run entrypoint.
CMD ["bash", "./start.sh"]
