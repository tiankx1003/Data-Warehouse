-- 建表
drop table ads_sale_tm_category1_stat_mn;
create external table ads_sale_tm_category1_stat_mn
(   
    tm_id string comment '品牌id',
    category1_id string comment '1级品类id ',
    category1_name string comment '1级品类名称 ',
    buycount   bigint comment  '购买人数',
    buy_twice_last bigint  comment '两次以上购买人数',
    buy_twice_last_ratio decimal(10,2)  comment  '单次复购率',
    buy_3times_last   bigint comment   '三次以上购买人数',
    buy_3times_last_ratio decimal(10,2)  comment  '多次复购率',
    stat_mn string comment '统计月份',
    stat_date string comment '统计日期' 
)   COMMENT '复购率统计'
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_sale_tm_category1_stat_mn/'
;
-- 导入数据
insert into table ads_sale_tm_category1_stat_mn
select   
    mn.sku_tm_id,
    mn.sku_category1_id,
    mn.sku_category1_name,
    sum(if(mn.order_count>=1,1,0)) buycount,
    sum(if(mn.order_count>=2,1,0)) buyTwiceLast,
    sum(if(mn.order_count>=2,1,0))/sum( if(mn.order_count>=1,1,0)) buyTwiceLastRatio,
    sum(if(mn.order_count>=3,1,0))  buy3timeLast  ,
    sum(if(mn.order_count>=3,1,0))/sum( if(mn.order_count>=1,1,0)) buy3timeLastRatio ,
    date_format('2019-08-28' ,'yyyy-MM') stat_mn,
    '2019-08-28' stat_date
from 
(
select 
        user_id, 
sd.sku_tm_id,
        sd.sku_category1_id,
        sd.sku_category1_name,
        sum(order_count) order_count
    from dws_sale_detail_daycount sd 
    where date_format(dt,'yyyy-MM')=date_format('2019-08-28' ,'yyyy-MM')
    group by user_id, sd.sku_tm_id, sd.sku_category1_id, sd.sku_category1_name
) mn
group by mn.sku_tm_id, mn.sku_category1_id, mn.sku_category1_name
;
-- 查询导入数据
select * from ads_sale_tm_category1_stat_mn;
