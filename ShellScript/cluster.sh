#! /bin/bash
case $1 in
"1"){
	echo " ---- 开启集群 "
	echo " >>>> 启动 hadoop集群 "
	hy 1
	echo " >>>> 启动 zookeeper集群 "
	zk 1
sleep 6s;
	echo " >>>> 启动 日志采集Flume "
	f1 1
	echo " >>>> 启动 kafka "
	kf 1
sleep 8s;
	echo " >>>> 启动 数据消费Flume "
	f2 1
	};;

"0"){
    echo " ---- 停止集群 "
	echo " <<<< 停止 数据消费Flume "
	f2 0
	echo " <<<< 停止 kafka "
	kf 0
sleep 8s;
	echo " <<<< 停止 日志采集Flume "
	f1 0
	echo " <<<< 停止 zookeeper集群 "
	zk 0
	echo " <<<< 停止 hadoop集群 "
	hy 0
};;
esac
