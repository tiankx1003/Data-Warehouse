#!/bin/bash
# 说明1：
# [ -n 变量值 ] 判断变量的值，是否为空
# -- 变量的值，非空，返回true
# -- 变量的值，为空，返回false
# 说明2：
# 查看date命令的使用，[tian@hadoop102 ~]$ date --help
# 企业开发中一般在每日凌晨30分~1点执行数据导入脚本

# 定义变量方便修改
APP=gmall
hive=$HIVE_HOME/bin/hive
hadoop=$HADOOP_HOME/bin/hadoop

# 如果是输入的日期按照取输入日期；如果没输入日期取当前时间的前一天
if [ -n "$1" ] ;then
   do_date=$1
else 
	do_date=`date -d "-1 day" +%F`
fi 

echo "===日志日期为 $do_date==="
sql="
load data inpath '/origin_data/gmall/log/topic_event/$do_date' into table "$APP".ods_event_log partition(dt='$do_date');
"

$hive -e "$sql"

# 为lzo压缩文件创建索引
hadoop jar $HADOOP_HOME/share/hadoop/common/hadoop-lzo-0.4.20.jar com.hadoop.compression.lzo.DistributedLzoIndexer /warehouse/gmall/ods/ods_event_log/dt=$do_date


ch="
select * from "$APP".ods_event_log where dt='"$do_date"' limit 10;
"
$hive -e "$ch"