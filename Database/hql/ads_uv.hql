-- dwd_start_log启动表，DWD对ODS层数据进行了去除空值，脏数据，超过极限范围的数据，行式存储改为列存储，改压缩格式
-- mid_id与user_id一致，需要用到的字段为mid_id和dt
select * from dwd_start_log limit 5;
set hive.exec.dynamic.partition.mode=nonstrict;

-- 1.客户活跃主题
  -- DWS活跃设备表
drop table if exists dws_uv_day;
create table dws_uv_day(mid_id string, os string) 
partitioned by(dt string)
stored as parquet 
location '/warehouse/gmall/dws/dws_uv_day';

drop table if exists dws_uv_wk;
create table dws_uv_wk(mid_id string, os string, 
	monday_date string comment '当周周一日期',
	sunday_day string comment '当周周日日期') comment '上周周活'
partitioned by(wk_dt string)
stored as parquet
location '/warehouse/gmall/dws/dws_uv_wk';

  -- 插入数据,TODO 同组的os字段未发生拼接聚合，自动去重?
  
insert overwrite table dws_uv_day partition(dt)
select mid_id,
    concat_ws('|',collect_set(os))  os, -- 根据mid_id分组后使用collect_set函数把每组的os聚合成数组，在使用concat拼接
    '2019-11-07' dt
from dwd_start_log 
where dt='2019-11-07' 
group by mid_id; -- 按照mid_id分组

insert overwrite table dws_uv_wk partition(wk_dt)
select mid_id,
	concat_ws('|',collect_set(os)) os,
	date_add(next_day('2019-11-07','MO'),-7) monday,
	date_add(next_day('2019-11-07','MO'),-1) sunday,
	concat(date_add(next_day('2019-11-07','MO'),-7),'_',date_add(next_day('2019-11-07','MO'),-1))
from dwd_start_log
where dt>=date_add(next_day('2019-11-07','MO'),-7) and dt<=date_add(next_day('2019-11-07','MO'),-1)
group by mid_id;

select * from dws_uv_day limit 10;
select * from dws_uv_wk limit 10;
select * from dwd_start_log limit 10;

  -- ADS活跃设备数
  
drop table if exists ads_uv_count;
create external table ads_uv_count(
	dt string comment '统计日期',
	day_count bigint comment '日活总数',
	wk_count bigint comment '周活总数',
	is_weekend string comment '是否是周末'
	) comment '活跃设备数'
row format delimited fields terminated by '\t'
location '/warehouse/gmall/dws/ads_uv_count';

  -- 插入数据
insert overwrite table ads_uv_count
select '2019-11-07' dt,
	daycount.ct,wkcount.ct,
	if(date_add(next_day('2019-11-07','MO'),-1)='2019-11-07','Y','N') -- 是否是周末
from
	(select '2019-11-07' dt, count(*) ct 
	from dws_uv_day
	where dt='2019-11-07') daycount
	join 
	(select '2019-11-07' dt, count(*) ct
	from dws_uv_wk
	where wk_dt=concat(date_add(next_day('2019-11-07','MO'),-7),'_',date_add(next_day('2019-11-07','MO'),-1))) wkcount
	on daycount.dt=wkcount.dt;

select * from ads_uv_count;

-- 2.用户新增主题
  -- DWS每日新增设备明细表


  -- ADS每日新增设备表

-- 3.用户留存主题
  -- DWS每日留存用户明细表

  -- DWS 1、2、3、n天留存用户明细表


  -- ADS留存用户数


  -- 留存用户比例

-- 4.沉默用户数
  -- DWS为dws_uv_detail_day
  -- ADS

-- 5.本周回流用户数
  -- DWS为dws_uv_detail_day
  -- ADS

-- 6.流失用户数
  -- DWS为dws_uv_detail_day
  -- ADS


-- 7.最近连续三周活跃用户数
  -- DWS为dws_uv_detail_week
  -- ADS

-- 8.最近七天连续活跃用户数
  -- DWS为dws_uv_detail_day

  -- ADS