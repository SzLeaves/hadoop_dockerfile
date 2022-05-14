# Hadoop Docker to build

[README in English](https://github.com/SzLeaves/hadoop_dockerfile/blob/main/readme_en.md)  
Docker images include hadoop, hbase, phoenix, zookeeper, based on `fedora:latest`.

该仓库构建的镜像包含hadoop, hbase, phoenix, zookeeper, 基于`fedora:latest`  


## 1. 安装Docker
docs: https://docs.docker.com/engine/install/  

如果你的发行版是CentOS 7，可以直接运行该脚本安装: `docker-install.sh`
```bash
#!/bin/bash
# CentOS 7 Docker install

cd /etc/yum.repos.d
sudo rm -rf *.repo
if [ -e CentOS-Base.repo.bak ]; then
    sudo mv CentOS-Base.repo.bak CentOS-Base.repo
fi
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org/centos|baseurl=https://mirrors.ustc.edu.cn/centos|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-Base.repo

sudo yum clean all
sudo yum makecache
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://mirrors.bfsu.edu.cn/docker-ce/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io

sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo docker version
sudo docker images
```

## 2. 在宿主机`hosts`文件中添加以下映射
```bash
172.30.0.100 master
172.30.0.101 slave-1
172.30.0.102 slave-2
```
> 如果在虚拟机中运行docker，则需要把上面的ip改成虚拟机网卡的ip  
> 并且需要在虚拟机软件内配置`172.30.0.100`网段下这些端口的转发规则  
> `2181, 8088, 9870, 16000, 16010, 16020`

## 3. 运行`build.sh`构建镜像
这个过程大概需要10分钟，请保证网络通畅  
运行后脚本会自动登录`hadoop-master`主节点容器  
登录后，运行`init.sh`进行hadoop及其他服务的初始化操作（**这个脚本不建议运行第二次**）  
之后可以使用`start.sh`启动集群，`stop.sh`关闭集群
> 在启动zookeeper的时候会显示`FAILED TO START`，但是我看了一下日志，暂时没有看到问题，其他服务运行也正常，如果你遇到了服务不正常的问题，请在issue中提出


## 3. 使用`cluster.sh`对创建的容器进行启动/关闭操作
> 使用这个脚本会自动启动/停止容器内集群的服务
* `./cluster.sh start` 启动集群，启动成功后会自动登录`hadoop-master`
* `./cluster.sh stop` 关闭集群

## 5. 使用`remove.sh`删除容器
运行这个脚本将删除之前创建的所有容器（包括给集群使用的网卡`hadoop`）

## 6. 使用`Phoenix JDBC`连接`Hbase`
* 使用数据库管理软件连接，需要自行导入`package`中Phoenix安装包的`client`jar文件(JDBC驱动)  
并且需要配置以下两个连接属性：  

| 属性                                      | 值                                                            |
|-------------------------------------------|---------------------------------------------------------------|
| phoenix.schema.isNamespaceMappingEnabled  | true                                                          |
| hbase.regionserver.wal.codec              | org.apache.hadoop.hbase.regionserver.wal.IndexedWALEditCodec  |

连接的JDBC URL: `jdbc:phoenix:172.30.0.100:2181`
> **如果docker在虚拟机中运行，则连接ip需要使用虚拟机网卡的ip，并且确认配置好hosts映射**
