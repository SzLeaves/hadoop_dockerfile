#!/bin/bash
if [[ $1 == "start" ]]; then
    docker start hadoop-master hadoop-slave-1 hadoop-slave-2
    docker ps -a | grep hadoop
    ssh root@master "source /etc/profile; bash /start.sh"
    docker exec -it hadoop-master /bin/bash
fi

if [[ $1 == "stop" ]]; then
    ssh root@master "source /etc/profile; bash /stop.sh"
    docker stop hadoop-master hadoop-slave-1 hadoop-slave-2
    docker ps -a | grep hadoop
fi
