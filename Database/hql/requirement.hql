-- dwd_start_log启动表，DWD对ODS层数据进行了去除空值，脏数据，超过极限范围的数据，行式存储改为列存储，改压缩格式
-- mid_id与user_id一致，需要用到的字段为mid_id和dt
select * from dwd_start_log limit 5;
set hive.exec.dynamic.partition.mode=nonstrict;

-- 1.客户活跃主题
  -- DWS活跃设备表
drop table if exists dws_uv_day;
create table dws_uv_day(mid_id string, os string) 
partitioned by(dt string)
stored as parquet -- parquet用于确定压缩格式?
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
    '2019-08-28' dt
from dwd_start_log 
where dt='2019-08-28' 
group by mid_id; -- 按照mid_id分组

insert overwrite table dws_uv_wk partition(wk_dt)
select mid_id,
	concat_ws('|',collect_set(os)) os,
	date_add(next_day('2019-08-28','MO'),-7) monday,
	date_add(next_day('2019-08-28','MO'),-1) sunday,
	concat(date_add(next_day('2019-08-28','MO'),-7),'_',date_add(next_day('2019-08-28','MO'),-1))
from dwd_start_log
where dt>=date_add(next_day('2019-08-28','MO'),-7) and dt<=date_add(next_day('2019-08-28','MO'),-1)
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
select '2019-08-28' dt,
	daycount.ct,wkcount.ct,
	if(date_add(next_day('2019-08-28','MO'),-1)='2019-08-28','Y','N') -- 是否是周末
from
	(select '2019-08-28' dt, count(*) ct 
	from dws_uv_day
	where dt='2019-08-28') daycount
	join 
	(select '2019-08-28' dt, count(*) ct
	from dws_uv_wk
	where wk_dt=concat(date_add(next_day('2019-08-28','MO'),-7),'_',date_add(next_day('2019-08-28','MO'),-1))) wkcount
	on daycount.dt=wkcount.dt;
  -- 验证
select * from ads_uv_count;

-- 2.用户新增主题
  -- DWS每日新增设备表
drop table if exists dws_new_mid_day;
create external table dws_new_mid_day(
	mid_id string,os string,create_date string)
stored as parquet
location '/warehouse/gmall/dws/dws_new_mid_day';
  -- 导入数据
insert into table dws_new_mid_day
select ud.mid_id,ud.os,'2019-08-28' dt
from 
	dws_uv_day ud 
	left join dws_new_mid_day nm
	on ud.mid_id=nm.mid_id
where ud.dt='2019-08-28' and nm.mid_id is null; -- 通过left join去除已有的即为新增的
  -- 验证
select * from dws_new_mid_day limit 10;

  -- ADS每日新增设备表
drop table if exists ads_new_mid_count;
create external table ads_new_mid_count(
	create_date string, new_mid_count bigint)
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_new_mid_count';

  -- 导入数据
insert into table ads_new_mid_count
select create_date, count(*)
from dws_new_mid_day
where create_date='2019-08-28'
group by create_date;
  --验证
-elect * from ads_new_mid_count;

-- 3.用户留存主题
  -- DWS每日留存用户表
drop table if exists dws_user_retention_day;
create external table dws_user_retention_day(
	mid_id string,create_date string,retention_day int)
partitioned by (dt string)
stored as parquet
location '/warehouse/gmall/dws/dws_user_retention_day';

  -- 导入数据,如果前一天的新增用户表数据为导入，则这次导入数据为空
insert into table dws_user_retention_day
partition(dt)
select 
	ud.mid_id,nm.create_date,1 retention_day,'2019-08-28' dt
from 
	dws_uv_day ud 
	join dws_new_mid_day nm
	on ud.mid_id=nm.mid_id
where ud.dt='2019-08-28' and nm.create_date=date_add('2019-08-28',-1);

  -- DWS 1、2、3、n天留存用户明细表
insert into table dws_user_retention_day
partition(dt)
select 
	ud.mid_id,nm.create_date,1 retention_day,'2019-08-28' dt
from 
	dws_uv_day ud 
	join dws_new_mid_day nm
	on ud.mid_id=nm.mid_id
where ud.dt='2019-08-28' and nm.create_date=date_add('2019-08-28',-1)
union all 
select 
	ud.mid_id,nm.create_date,2 retention_day,'2019-08-28' dt
from 
	dws_uv_day ud 
	join dws_new_mid_day nm
	on ud.mid_id=nm.mid_id
where ud.dt='2019-08-28' and nm.create_date=date_add('2019-08-28',-2)
union all
select 
	ud.mid_id,nm.create_date,3 retention_day,'2019-08-28' dt
from 
	dws_uv_day ud 
	join dws_new_mid_day nm
	on ud.mid_id=nm.mid_id
where ud.dt='2019-08-28' and nm.create_date=date_add('2019-08-28',-3)

  -- ADS留存用户数
drop table if exists ads_user_retention_day_count;
create external table ads_user_retention_day_count(
	create_date string comment '用户新增日期',
	retention_day int comment '用户留存天数',
	retention_count bigint comment '留存用户数')
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_user_retention_day_count';

  -- 导入数据
insert into table ads_user_retention_day_count
select create_date,retention_day,count(*)
from dws_user_retention_day
where dt='2019-08-28'
group by create_date,retention_day;

  -- 留存用户比例
drop table if exists ads_user_retention_day_rate;
create external table ads_user_retention_day_rate(
	stat_date string comment '统计日期',
	create_date string comment '新增日期',
	retention_day string comment '截至当前用户留存天数',
	retention_count bigint comment '留存数量',
	new_mid_count bigint comment '当日新增用户数',
	retention_ratio decimal(10,2) comment '留存率') comment '每日用户留存状况'
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_user_retention_day_rate';

  -- 导入数据
insert into table ads_user_retention_day_rate
select 
	'2019-08-28' stat_date,
	ur.create_date create_date,
	ur.retention_day retention_day,
	ur.retention_count retention_count,
	nc.new_mid_count new_mid_count,
	ur.retention_count/nc.new_mid_count*100 retention_ratio
from 
	ads_user_retention_day_count ur 
	join ads_new_mid_count nc
	on ur.create_date=nc.create_date;
	
	
-- 4.沉默用户数,在此之前活跃次数为1且不是近一周
  -- DWS为dws_uv_day
  -- ADS
drop table if exists ads_silent_count;
create external table ads_silent_count(
	dt string comment '统计日期',
	silent_count bigint comment '沉默用户数')
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_silent_count';

  -- 导入数据
insert into table ads_silent_count
select
	'2019-08-28' dt,
	count(*) silent_count
from 
	(select mid_id
	from dws_uv_day
	where dt<='2019-08-28'
	group by mid_id
	having count(*)=1 and max(dt)<date_add('2019-08-28',-7)) t1;

-- 5.本周回流用户数,本周回流=本周活跃-本周新增-上周活跃
  -- DWS为dws_uv_day
  -- ADS
drop table if exists ads_back_count;
create external table ads_back_count(
	dt string comment '统计日期',
	wk_dt string comment '统计日期所在周',
	back_count bigint comment '回流用户数')
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_back_count';

  -- 导入数据
insert into table ads_back_count
select 
	'209-08-28' dt,
	concat(date_add(next_day('2019-08-28','MO'),-7),'_',date_add(next_day('2019-08-28','MO'),-1)) wk_dt,
	count(*) back_count
from 
	(
		select t1.mid_id
		from 
		(
			select mid_id
			from dws_uv_wk
			where wk_dt=concat(date_add(next_day('2019-08-28','MO'),-7),'_',date_add(next_day('2019-08-28','MO'),-1))
		) t1
		left join 
		(
			select mid_id
			from dws_new_mid_day
			where create_date between date_add(next_day('2019-08-28','MO'),-7) and date_add(next_day('2019-08-28','MO'),-1)
		) t2
		on t1.mid_id=t2.mid_id
		left join 
		(
			select mid_id
			from dws_uv_wk
			where wk_dt=concat(date_add(next_day('2019-08-28','MO'),-14),'_',date_add(next_day('2019-08-28','MO'),-7-1))
		) t3
		on t1.mid_id=t3.mid_id
		where t2.mid_id is null and t3.mid_id is null 
	) t4;

select * from ads_back_count;

-- 6.流失用户数
  -- DWS为dws_uv_day
  -- ADS
drop table if exists ads_wastage_count;
create external table ads_wastage_count(
	dt string comment '统计日期',
	wastage_count bigint comment '流式设备数')
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_wastage_count';

  -- 导入数据
insert into table ads_wastage_count
select 
	'2019-08-28' dt,
	count(*)
from 
	(
		select mid_id
		from dws_uv_day
		group by mid_id
		having max(dt)<=date_add('2019-08-28',-7)
	) t1;

-- 7.最近连续三周活跃用户数
  -- DWS为dws_uv_detail_wk
  -- ADS
drop table if exists ads_continuity_wk_count;
create external table ads_continuity_wk_count(
	dt string comment '统计时间',
	wk_dt string comment '持续时间',
	continuity_count bigint comment '用户数')
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads_continuity_wk_count';

  -- 导入数据
insert into table ads_continuity_wk_count
select 
	'2019-08-28' dt,
	concat_ws(date_add('2019-08-28',-21),'_',date_add('2019-08-28',-1)) wk_dt,
	count(*) continuity
from 
	(
		select mid_id
		from dws_uv_wk
		where wk_dt>=concat_ws(date_add('2019-08-28',-21),'_',date_add('2019-08-28',-14-1)) and 
			wk_dt>=concat_ws(date_add('2019-08-28',-7),'_',date_add('2019-08-28',-1))
		group by mid_id
		having count(*)=3
	) t1;

-- 8.最近七天连续活跃三天用户数
  -- DWS为dws_uv_day
  -- ADS
drop table if exists ads_continuity_uv_count;
create external table ads_continuity_uv_count(
	dt string comment '统计时间',
	wk_dt string comment '持续时间',
	countinuity_count bigint comment '用户数')
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_continuity_uv_count';

  -- 插入数据
insert into table ads_continuity_uv_count
select 
	'2019-08-28' dt,
	concat_ws(date_add('2019-08-28',-6),'_','2019-08-28') wk_dt,
	count(*) countinuity_count
from
	(
		select mid_id
		from 
			(
				select mid_id
				from 
					(
						-- 求活跃日期和序号的差值，差值一致则为连续活跃
						select mid_id,date_sub(dt,rank) date_dif
						from 
							(
								-- 开窗，为每个mid_id按照活跃的日期分配序号
								select mid_id,dt,rank() over(partition by mid_id order by dt) rank
								from dws_uv_day
								where dt between date_add('2019-08-28',-6) and '2019-08-28'
							) t1
					) t2
				group by mid_id, date_dif
				having count(*)>=3
			) t3
		group by mid_id -- 去重，有123,567两次连续三天的用户，这种只计一次
	) t4;