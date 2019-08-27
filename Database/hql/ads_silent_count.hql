-- 1）建表语句
drop table if exists ads_silent_count;
create external table ads_silent_count( 
    `dt` string COMMENT '统计日期',
    `silent_count` bigint COMMENT '沉默设备数'
) 
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_silent_count';

-- 2）导入2019-02-20数据
insert into table ads_silent_count
select 
    '2019-02-20' dt,
    count(*) silent_count
from 
(
    select mid_id
    from dws_uv_detail_day
    where dt<='2019-02-20'
    group by mid_id
    having count(*)=1 and min(dt)<date_add('2019-02-20',-7)
) t1;

-- 3）查询导入数据
select * from ads_silent_count;
