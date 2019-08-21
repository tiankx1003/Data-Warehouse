#!/bin/bash
for i in `cat /opt/module/hadoop-2.7.2/etc/hadoop/slaves`
do
    echo "========== $i ==========" 
    ssh $i 'source /etc/profile&&/opt/module/kafka/bin/kafka-server-stop.sh'
    echo $?
done