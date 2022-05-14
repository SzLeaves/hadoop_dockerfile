#!/bin/bash
docker stop hadoop-master hadoop-slave-1 hadoop-slave-2
docker rm hadoop-master hadoop-slave-1 hadoop-slave-2
docker rmi hadoop-docker
docker network rm hadoop
docker ps -a
docker images
docker network ls
rm -f Dockerfile
