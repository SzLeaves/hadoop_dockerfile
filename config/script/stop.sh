#!/bin/bash

# stop hbase
stop-hbase.sh

# stop hadoop
stop-yarn.sh
stop-dfs.sh

# stop zookeeper
for node in master slave-1 slave-2
do
        ssh $node "source /etc/profile; zkServer.sh stop"
done

# check nodes jps
source nodejps.sh
