-- 用户行为漏斗分析
-- 建表
drop table if exists ads_user_action_convert_day;
create external  table ads_user_action_convert_day(
    `dt` string COMMENT '统计日期',
    `total_visitor_m_count`  bigint COMMENT '总访问人数',
    `order_u_count` bigint     COMMENT '下单人数',
    `visitor2order_convert_ratio`  decimal(10,2) COMMENT '访问到下单转化率',
    `payment_u_count` bigint     COMMENT '支付人数',
    `order2payment_convert_ratio` decimal(10,2) COMMENT '下单到支付的转化率'
 ) COMMENT '用户行为漏斗分析'
row format delimited  fields terminated by '\t'
location '/warehouse/gmall/ads/ads_user_action_convert_day/'
;
-- 导入数据
insert into table ads_user_action_convert_day
select 
    '2019-08-28',
    uv.day_count,
    ua.order_count,
    cast(ua.order_count/uv.day_count as  decimal(10,2)) visitor2order_convert_ratio,
    ua.payment_count,
    cast(ua.payment_count/ua.order_count as  decimal(10,2)) order2payment_convert_ratio
from  
    (
        select 
            dt,
            sum(if(order_count>0,1,0)) order_count,
            sum(if(payment_count>0,1,0)) payment_count
        from dws_user_action
        where dt='2019-08-28'
        group by dt
    )ua join ads_uv_count  uv on uv.dt=ua.dt
;
-- 查询导入数据
select * from ads_user_action_convert_day;
