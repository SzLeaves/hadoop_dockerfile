# Hadoop Docker to build

## 1. Install Docker
docs: https://docs.docker.com/engine/install/  

if your distribution is **CentOS 7**, you can run this script: `docker-install.sh`
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

## 2. Adding ip mappings to system hosts file
Add the following mappings to `hosts` file
```bash
172.30.0.100 master
172.30.0.101 slave-1
172.30.0.102 slave-2
```

## 3. Run `build.sh` to build docker images
This process need network, It takes about 10 minutes.  
After the build is successful, script will login hadoop master node automatically.

In the container, you can run `init.sh` to initialize cluster (This script will start cluster automatically)  
**No recommend** run this script twice.  

After initialize, you can run `start.sh` to start cluster and `stop.sh` to stop cluster.

## 4. Use `cluster.sh` to control containers start/stop
These script are start/stop cluster in containers automatically.
* `./cluster.sh start` to **start** docker containers  
* `./cluster.sh stop` to **stop** docker containers  

## 5. Use `remove.sh` to remove all build containers
This script will remove all docker containers before using `build.sh` to build, include docker network bridge called `hadoop`.
