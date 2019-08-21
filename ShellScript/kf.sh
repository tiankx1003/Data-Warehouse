#! /bin/bash

case $1 in
"start"){
        for i in `cat /opt/module/hadoop-2.7.2/etc/hadoop/slaves`
        do
                echo " --------启动 $i Kafka-------"
                # 用于KafkaManager监控
                ssh $i "export JMX_PORT=9988 && /opt/module/kafka/bin/kafka-server-start.sh -daemon /opt/module/kafka/config/server.properties "
        done
};;
"stop"){
        for i in `cat /opt/module/hadoop-2.7.2/etc/hadoop/slaves`
        do
                echo " --------停止 $i Kafka-------"
                ssh $i "/opt/module/kafka/bin/kafka-server-stop.sh stop"
        done
};;
esac
