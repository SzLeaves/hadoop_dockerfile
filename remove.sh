#!/bin/bash
sudo docker stop mysql-hive
sudo docker stop hadoop-master hadoop-slave-1 hadoop-slave-2

sudo docker rm mysql-hive
sudo docker rm hadoop-master hadoop-slave-1 hadoop-slave-2
sudo docker rmi hadoop-docker
sudo docker network rm hadoop

sudo docker ps -a
sudo docker images
sudo docker network ls
rm -f Dockerfile
