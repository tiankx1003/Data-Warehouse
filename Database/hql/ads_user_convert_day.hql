-- 用户新鲜度
-- 建表
drop table if exists ads_user_convert_day;
create external table ads_user_convert_day( 
    `dt` string COMMENT '统计日期',
    `uv_m_count`  bigint COMMENT '当日活跃设备',
    `new_m_count`  bigint COMMENT '当日新增设备',
    `new_m_ratio`   decimal(10,2) COMMENT '当日新增占日活的比率'
) COMMENT '转化率'
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_user_convert_day/'
;
-- 导入数据
insert into table ads_user_convert_day
select
    '2019-11-07',
    sum(uc.dc) sum_dc,
    sum(uc.nmc) sum_nmc,
    cast(sum( uc.nmc)/sum( uc.dc)*100 as decimal(10,2))  new_m_ratio
from 
(
    select
        day_count dc,
        0 nmc
    from ads_uv_count
    where dt='2019-11-07'

    union all
    select
        0 dc,
        new_mid_count nmc
    from ads_new_mid_count
    where create_date='2019-11-07'
)uc;
-- 查看导入的数据
select * from ads_user_convert_day;
