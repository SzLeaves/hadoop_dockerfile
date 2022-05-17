#!/bin/bash

# start zookeeper
for node in master slave-1 slave-2
do
        ssh $node "source /etc/profile; zkServer.sh start"
done

# start hadoop
start-dfs.sh
start-yarn.sh
# start hbase
start-hbase.sh

# check nodes jps
source /nodejps.sh
