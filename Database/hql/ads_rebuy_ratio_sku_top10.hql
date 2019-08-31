create external table ads_rebuy_ratio_sku_top10(
    user_level string comment '用户等级',
    sku_id string comment '商品id',
    rebuy_ratio decimal(10,2) comment '复购率',
    rank_num int comment '排名'
)comment '每个等级的用户对应的复购率排名前十的商品排行'
partitioned by (dt string)
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_rebuy_ratio_sku_top10';

  -- 插入数据
insert into table ads_rabuy_ratio_sku_top10
select
    t2.user_level,
    t2.sku_id,
    t2.rebuy_ratio,
    t2.rank_num
from(
    select 
        t1.user_level user_level,
        t1.sku_id sku_id,
        t1.rebuy_ratio rebuy_ratio,
        rank() over(order by rebuy_ratio desc) rank_num
    from
        (select
            user_level,
            sku_id,
            cast(sum(if(mn.order_count>2,1,0))/sum(if(mn.order_count>1,1,0))as decimal(10,2)) rebuy_ratio
        from dws_sal_detail_daycount
        where dt='2019-08-28'
        group by user_level,sku_id) t1
        )t2
where rank_num<=10;