#!/bin/bash
# CentOS 7 Docker install

cd /etc/yum.repos.d
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org/centos|baseurl=https://mirrors.ustc.edu.cn/centos|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-Base.repo

sudo yum clean all
sudo yum makecache
sudo yum install -y yum-utils --nogpgcheck
sudo yum-config-manager --add-repo https://mirrors.bfsu.edu.cn/docker-ce/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io wget ca-certificates --nogpgcheck

sudo systemctl enable docker.service
sudo systemctl start docker.service

# docker mirrors
echo "{\"registry-mirrors\":[\"https://docker.mirrors.ustc.edu.cn/\"]}" | sudo tee /etc/docker/daemon.json
sudo systemctl daemon-reload
sudo systemctl restart docker

sudo systemctl status docker.service
sudo docker version
sudo docker images
