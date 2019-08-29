create external table ads_rebuy_ratio_sku_top10(
    user_level string comment '用户等级',
    sku_id string comment '商品id',
    rebuy_ratio decimal(10,2) comment '复购率',
    rank_num int comment '排名'
)comment '每个等级的用户对应的复购率排名前十的商品排行'
partitioned by (dt string)
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_rebuy_ratio_sku_top10';

select 
    user_level,
    sku_id,
    rebuy_ratio,
    rank() over(order by rebuy_ratio desc) rank_num
from
    (select
        user_level,
        sku_id,
        cast()
    from dws_sal_detail_daycount
    where )
    -- TODO 待完成