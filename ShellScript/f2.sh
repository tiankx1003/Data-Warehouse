#! /bin/bash

case $1 in
"1"){
        for i in hadoop104
        do
                echo " --------启动 $i 消费flume-------"
                ssh $i "nohup $FLUME_HOME/bin/flume-ng agent --conf-file $FLUME_HOME/conf/kafka-flume-hdfs.conf --name a1 -Dflume.root.logger=INFO,LOGFILE >$FLUME_HOME/log.txt   2>&1 &"
        done
};;
"0"){
        for i in hadoop104
        do
                echo " --------停止 $i 消费flume-------"
                ssh $i "ps -ef | grep kafka-flume-hdfs | grep -v grep |awk '{print \$2}' | xargs kill"
        done

};;
esac
