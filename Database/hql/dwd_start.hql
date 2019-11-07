-- 创建启动表
drop table if exists dwd_start_log;
CREATE EXTERNAL TABLE dwd_start_log(
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
    `entry` string, 
    `open_ad_type` string, 
    `action` string, 
    `loading_time` string, 
    `detail` string, 
    `extend1` string
    )
PARTITIONED BY (dt string)
stored as parquet
location '/warehouse/gmall/dwd/dwd_start_log/'
TBLPROPERTIES('parquet.compression'='lzo');

-- 向表中导入数据
insert overwrite table dwd_start_log
PARTITION (dt='2019-11-07')
select 
    get_json_object(line,'$.mid') mid_id,
    get_json_object(line,'$.uid') user_id,
    get_json_object(line,'$.vc') version_code,
    get_json_object(line,'$.vn') version_name,
    get_json_object(line,'$.l') lang,
    get_json_object(line,'$.sr') source,
    get_json_object(line,'$.os') os,
    get_json_object(line,'$.ar') area,
    get_json_object(line,'$.md') model,
    get_json_object(line,'$.ba') brand,
    get_json_object(line,'$.sv') sdk_version,
    get_json_object(line,'$.g') gmail,
    get_json_object(line,'$.hw') height_width,
    get_json_object(line,'$.t') app_time,
    get_json_object(line,'$.nw') network,
    get_json_object(line,'$.ln') lng,
    get_json_object(line,'$.la') lat,
    get_json_object(line,'$.entry') entry,
    get_json_object(line,'$.open_ad_type') open_ad_type,
    get_json_object(line,'$.action') action,
    get_json_object(line,'$.loading_time') loading_time,
    get_json_object(line,'$.detail') detail,
    get_json_object(line,'$.extend1') extend1
from ods_start_log 
where dt='2019-11-07';

-- 验证
select * from dwd_start_log limit 2;


