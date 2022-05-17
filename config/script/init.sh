#!/bin/bash
ssh-keygen
ssh-copy-id master
ssh-copy-id slave-1
ssh-copy-id slave-2

echo "1" > myid && scp myid root@master:/usr/local/zookeeper/data/myid
echo "2" > myid && scp myid root@slave-1:/usr/local/zookeeper/data/myid
echo "3" > myid && scp myid root@slave-2:/usr/local/zookeeper/data/myid
rm -f myid

for node in master slave-1 slave-2
do
    ssh $node "source /etc/profile; zkServer.sh start"
done

# init and start cluster
hdfs namenode -format
start-dfs.sh
start-yarn.sh
start-hbase.sh

# check nodes jps
source /nodejps.sh
