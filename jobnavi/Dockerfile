# Tencent is pleased to support the open source community by making BK-BASE 蓝鲸基础平台 available.
#
# Copyright (C) 2021 THL A29 Limited, a Tencent company.  All rights reserved.
#
# BK-BASE 蓝鲸基础平台 is licensed under the MIT License.
#
# License for BK-BASE 蓝鲸基础平台:
# --------------------------------------------------------------------
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial
# portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
FROM centos:7

ARG BASE_DIR=/data
ARG WORK_DIR=$BASE_DIR

RUN yum -y update \
    && yum -y install wget \
    && yum -y install iputils \
    && yum -y install tcpdump \
    && yum -y install telnet \
    && yum -y install net-tools \
    && yum -y install procps \
    && yum -y install gettext

# 安装 kona-jdk
ENV JAVA_HOME $WORK_DIR/jdk
ENV PATH $JAVA_HOME/bin:$PATH
WORKDIR $JAVA_HOME

COPY konajdk.tar.gz ./
RUN set -ex \
     tar -xvzf konajdk.tar.gz -C $JAVA_HOME --strip-components 1 \
    && rm konajdk.tar.gz
# 设置字符编码
ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

RUN mkdir -p $BASE_DIR/bkee/jobnavi/jobnavischeduler

COPY bkdata/jobnavischeduler $BASE_DIR/bkee/jobnavi/jobnavischeduler
RUN mkdir -p $BASE_DIR/bkee/logs/jobnavi/jobnavi-scheduler
RUN adduser dataflow
WORKDIR $BASE_DIR/bkee/jobnavi/jobnavischeduler