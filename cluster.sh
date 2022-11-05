#!/bin/bash
if [[ $1 == "start" ]]; then
    sudo docker start mysql-hive
    sudo docker start hadoop-master hadoop-slave-1 hadoop-slave-2
    sudo docker ps -a | grep hadoop
    ssh root@master "source /etc/profile; bash /start.sh"
    sudo docker exec -it hadoop-master /bin/bash
fi

if [[ $1 == "stop" ]]; then
    ssh root@master "source /etc/profile; bash /stop.sh"
    sudo docker stop hadoop-master hadoop-slave-1 hadoop-slave-2
    sudo docker stop mysql-hive
    sudo docker ps -a | grep hadoop
fi
