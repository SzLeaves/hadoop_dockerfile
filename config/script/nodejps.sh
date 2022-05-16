#!/bin/bash

# check nodes jps
for node in master slave-1 slave-2
do
        echo "--> $node jps <---"
        ssh $node "source /etc/profile; jps"
done
