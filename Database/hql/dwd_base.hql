
-- 创建事件表 - 基础明细表
drop table if exists dwd_base_event_log;
CREATE EXTERNAL TABLE dwd_base_event_log(
    `mid_id` string,
    `user_id` string, 
    `version_code` string, 
    `version_name` string, 
    `lang` string, 
    `source` string, 
    `os` string, 
    `area` string, 
    `model` string,
    `brand` string, 
    `sdk_version` string, 
    `gmail` string, 
    `height_width` string, 
    `app_time` string, 
    `network` string, 
    `lng` string, 
    `lat` string, 
    `event_name` string, 
    `event_json` string, 
    `server_time` string)
PARTITIONED BY (`dt` string)
stored as parquet
location '/warehouse/gmall/dwd/dwd_base_event_log/'
TBLPROPERTIES('parquet.compression'='lzo');

-- 创建解析事件日志基础明细表
set hive.exec.dynamic.partition.mode=nonstrict;

insert overwrite table dwd_base_event_log partition(dt='2019-08-24')
select
    base_analizer(line,'mid') as mid_id,
    base_analizer(line,'uid') as user_id,
    base_analizer(line,'vc') as version_code,
    base_analizer(line,'vn') as version_name,
    base_analizer(line,'l') as lang,
    base_analizer(line,'sr') as source,
    base_analizer(line,'os') as os,
    base_analizer(line,'ar') as area,
    base_analizer(line,'md') as model,
    base_analizer(line,'ba') as brand,
    base_analizer(line,'sv') as sdk_version,
    base_analizer(line,'g') as gmail,
    base_analizer(line,'hw') as height_width,
    base_analizer(line,'t') as app_time,
    base_analizer(line,'nw') as network,
    base_analizer(line,'ln') as lng,
    base_analizer(line,'la') as lat,
    event_name,
    event_json,
    base_analizer(line,'st') as server_time
from ods_event_log lateral view flat_analizer(base_analizer(line,'et')) tmp_flat as event_name,event_json
where dt='2019-08-24' and base_analizer(line,'et')<>'';