-- 1）建表语句
drop table if exists ads_continuity_wk_count;
create external table ads_continuity_wk_count( 
    `dt` string COMMENT '统计日期,一般用结束周周日日期,如果每天计算一次,可用当天日期',
    `wk_dt` string COMMENT '持续时间',
    `continuity_count` bigint
) 
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_continuity_wk_count';
-- 2）导入2019-02-20所在周的数据
insert into table ads_continuity_wk_count
select 
     '2019-02-20',
     concat(date_add(next_day('2019-02-20','MO'),-7*3),'_',date_add(next_day('2019-02-20','MO'),-1)),
     count(*)
from 
(
    select mid_id
    from dws_uv_detail_wk
    where wk_dt>=concat(date_add(next_day('2019-02-20','MO'),-7*3),'_',date_add(next_day('2019-02-20','MO'),-7*2-1)) 
    and wk_dt<=concat(date_add(next_day('2019-02-20','MO'),-7),'_',date_add(next_day('2019-02-20','MO'),-1))
    group by mid_id
    having count(*)=3
)t1;
-- 3）查询
select * from ads_continuity_wk_count;
