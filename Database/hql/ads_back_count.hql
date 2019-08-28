-- 1）建表语句
drop table if exists ads_back_count;
create external table ads_back_count( 
    `dt` string COMMENT '统计日期',
    `wk_dt` string COMMENT '统计日期所在周',
    `back_count` bigint COMMENT '回流设备数'
) 
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_back_count';
-- 2）导入数据
insert into table ads_back_count
select 
   '2019-02-20' dt,
   concat(date_add(next_day('2019-02-20','MO'),-7),'_',date_add(next_day('2019-02-20','MO'),-1)) wk_dt,
   count(*)
from 
(
    select t1.mid_id
    from 
    (
        select	mid_id
        from dws_uv_detail_wk
        where wk_dt=concat(date_add(next_day('2019-02-20','MO'),-7),'_',date_add(next_day('2019-02-20','MO'),-1))
    )t1
    left join
    (
        select mid_id
        from dws_new_mid_day
        where create_date<=date_add(next_day('2019-02-20','MO'),-1) and create_date>=date_add(next_day('2019-02-20','MO'),-7)
    )t2
    on t1.mid_id=t2.mid_id
    left join
    (
        select mid_id
        from dws_uv_detail_wk
        where wk_dt=concat(date_add(next_day('2019-02-20','MO'),-7*2),'_',date_add(next_day('2019-02-20','MO'),-7-1))
    )t3
    on t1.mid_id=t3.mid_id
    where t2.mid_id is null and t3.mid_id is null
)t4;
-- 3）查询结果
select * from ads_back_count;

