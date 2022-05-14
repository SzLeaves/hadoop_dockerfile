#!/bin/bash

# 安装文件名称
JDK_TAR="jdk8u332-b09.tar.gz"
JDK_DEST="jdk8u332-b09"

HA_TAR="hadoop-3.2.3.tar.gz"
HA_DEST="hadoop-3.2.3"

HB_TAR="hbase-2.4.12-bin.tar.gz"
HB_DEST="hbase-2.4.12"

ZK_TAR="apache-zookeeper-3.7.1-bin.tar.gz"
ZK_DEST="apache-zookeeper-3.7.1-bin"

PH_TAR="phoenix-hbase-2.4-5.1.2-bin.tar.gz"
PH_DEST="phoenix-hbase-2.4-5.1.2-bin"

# 下载安装包
if [ ! -d packages ]; then
    mkdir packages
fi
cd packages

is_jdk_tar=$(ls | grep $JDK_TAR)
if [[ ! $is_jdk_tar != "" ]]; then
    wget -c https://mirrors.tuna.tsinghua.edu.cn/Adoptium/8/jdk/x64/linux/OpenJDK8U-jdk_x64_linux_hotspot_8u332b09.tar.gz \
        -O $JDK_TAR
fi

is_ha_tar=$(ls | grep $HA_TAR)
if [[ ! $is_ha_tar != "" ]]; then
    wget -c https://mirrors.bfsu.edu.cn/apache/hadoop/common/$HA_DEST/$HA_TAR
fi

is_hb_tar=$(ls | grep $HB_TAR)
if [[ ! $is_hb_tar != "" ]]; then
    wget -c https://mirrors.bfsu.edu.cn/apache/hbase/2.4.12/$HB_TAR
fi

is_zk_tar=$(ls | grep $ZK_TAR)
if [[ ! $is_zk_tar != "" ]]; then
    wget -c https://mirrors.bfsu.edu.cn/apache/zookeeper/zookeeper-3.7.1/$ZK_TAR
fi

is_ph_tar=$(ls | grep $PH_TAR)
if [[ ! $is_ph_tar != "" ]]; then
    wget -c https://mirrors.bfsu.edu.cn/apache/phoenix/phoenix-5.1.2/$PH_TAR
fi


if [ ! -e $JDK_TAR ] || [ ! -e $HA_TAR ] || [ ! -e $HB_TAR ] || [ ! -e $ZK_TAR ] || [ ! -e $PH_TAR ]; then
    echo "Failure: No install packages"
    exit 1
fi

# 替换dockerfile模板
cd ../
if [ ! -e Dockerfile.templete ]; then
    echo "Failure: No dockerfile templete"
    exit 1
fi

cp -f Dockerfile.templete Dockerfile
cat Dockerfile | sed -e "s/{Hadoop_Src}/$HA_TAR/" \
-e "s/{JDK_Src}/$JDK_TAR/g" \
-e "s/{Hbase_Src}/$HB_TAR/g" \
-e "s/{ZK_Src}/$ZK_TAR/g" \
-e "s/{PH_Src}/$PH_TAR/g" \
-e "s/{Hadoop_Dir}/$HA_DEST/g" \
-e "s/{JDK_Dir}/$JDK_DEST/g" \
-e "s/{Hbase_Dir}/$HB_DEST/g" \
-e "s/{ZK_Dir}/$ZK_DEST/g" \
-e "s/{PH_Dir}/$PH_DEST/g" \
-i Dockerfile

# 将映射写入宿主机/etc/hosts
echo '172.30.0.100 master'  | sudo tee -a /etc/hosts
echo '172.30.0.101 slave-1' | sudo tee -a /etc/hosts
echo '172.30.0.102 slave-2' | sudo tee -a /etc/hosts

# 新建docker网卡
is_network=$(sudo docker network ls | grep "hadoop")
if [[ ! $is_network != "" ]]; then
    sudo docker network create --driver bridge --subnet=172.30.0.0/24 --gateway=172.30.0.1 hadoop
fi

# 构建容器
sudo docker build -t 'hadoop-docker' .

# 运行容器
sudo docker run --name hadoop-master --hostname master \
    --add-host master:172.30.0.100 \
    --add-host slave-1:172.30.0.101 \
    --add-host slave-2:172.30.0.102 \
    --net hadoop --ip 172.30.0.100 -d -P \
    -p 2181:2181 -p 9870:9870 -p 8088:8088 -p 16000:16000 -p 16010:16010 -p 16020:16020 hadoop-docker

sudo docker run --name hadoop-slave-1 --hostname slave-1 \
    --add-host master:172.30.0.100 \
    --add-host slave-1:172.30.0.101 \
    --add-host slave-2:172.30.0.102 \
    --net hadoop --ip 172.30.0.101 -d -P -p 2182:2181 hadoop-docker

sudo docker run --name hadoop-slave-2 --hostname slave-2 \
    --add-host master:172.30.0.100 \
    --add-host slave-1:172.30.0.101 \
    --add-host slave-2:172.30.0.102 \
    --net hadoop --ip 172.30.0.102 -d -P -p 2183:2181 hadoop-docker

# 进入hadoop-master实例
sudo docker exec -it hadoop-master /bin/bash
