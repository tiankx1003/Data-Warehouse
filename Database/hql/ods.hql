-- 创建gmall数据库
drop database gmall cascade; -- 如果数据库已存在且有数据,执行强制删除
create database gmall; 
use gmall;
-- 创建启动日志表ods_start_log
-- 创建输入数据是lzo输出是text，支持json解析的分区表
drop table if exists ods_start_log;
CREATE EXTERNAL TABLE ods_start_log (`line` string)
PARTITIONED BY (`dt` string)
STORED AS
  INPUTFORMAT 'com.hadoop.mapred.DeprecatedLzoTextInputFormat'
  OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION '/warehouse/gmall/ods/ods_start_log';
-- 加载数据
load data inpath '/origin_data/gmall/log/topic_start/2019-08-24' 
into table gmall.ods_start_log partition(dt='2019-08-24');
-- 验证
select * from ods_start_log limit 2;

-- 创建事件日志表ods_event_log
drop table if exists ods_event_log;
CREATE EXTERNAL TABLE ods_event_log(`line` string)
PARTITIONED BY (`dt` string)
STORED AS
  INPUTFORMAT 'com.hadoop.mapred.DeprecatedLzoTextInputFormat'
  OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION '/warehouse/gmall/ods/ods_event_log';
-- 加载数据
load data inpath '/origin_data/gmall/log/topic_event/2019-08-24' 
into table gmall.ods_event_log partition(dt='2019-08-24');
-- 验证
select * from ods_event_log limit 2;