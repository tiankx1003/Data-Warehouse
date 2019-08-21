#! /bin/bash

case $1 in
"start"){
	for i in `cat /opt/module/hadoop-2.7.2/etc/hadoop/slaves`
	do
		ssh $i "/opt/module/zookeeper-3.4.10/bin/zkServer.sh start"
	done
};;
"stop"){
	for i in `cat /opt/module/hadoop-2.7.2/etc/hadoop/slaves`
	do
		ssh $i "/opt/module/zookeeper-3.4.10/bin/zkServer.sh stop"
	done
};;
"status"){
	for i in `cat /opt/module/hadoop-2.7.2/etc/hadoop/slaves`
	do
		ssh $i "/opt/module/zookeeper-3.4.10/bin/zkServer.sh status"
	done
};;
esac
