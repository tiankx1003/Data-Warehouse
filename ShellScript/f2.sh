#! /bin/bash

case $1 in
"1"){
        for i in hadoop104
        do
                echo " --------启动 $i 消费flume-------"
                ssh $i "nohup $FLUME_HOME/bin/flume-ng agent -n a1 -c $FLUME_HOME/conf/ -f $FLUME_HOME/job/kafka-flume-hdfs.conf -Dflume.root.logger=INFO,LOGFILE >$FLUME_HOME/logs/log.txt   2>&1 &"
        done
};;
"0"){
        for i in hadoop104
        do
                echo " --------停止 $i 消费flume-------"
                ssh $i "ps -ef | grep kafka-flume-hdfs | grep -v grep |awk '{print \$2}' | xargs kill"
		ssh $i "ps -ef | grep kafka-flume-hdfs | grep -v grep |awk '{print \$2}' | xargs kill -9"
                
        done
};;
esac
