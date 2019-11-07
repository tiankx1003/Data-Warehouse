-- 建表
drop table if exists dws_sale_detail_daycount;
create external table dws_sale_detail_daycount
(   
    user_id   string  comment '用户 id',
    sku_id    string comment '商品 Id',
    user_gender  string comment '用户性别',
    user_age string  comment '用户年龄',
    user_level string comment '用户等级',
    order_price decimal(10,2) comment '商品价格',
    sku_name string   comment '商品名称',
    sku_tm_id string   comment '品牌id',
    sku_category3_id string comment '商品三级品类id',
    sku_category2_id string comment '商品二级品类id',
    sku_category1_id string comment '商品一级品类id',
    sku_category3_name string comment '商品三级品类名称',
    sku_category2_name string comment '商品二级品类名称',
    sku_category1_name string comment '商品一级品类名称',
    spu_id  string comment '商品 spu',
    sku_num  int comment '购买个数',
    order_count string comment '当日下单单数',
    order_amount string comment '当日下单金额'
) COMMENT '用户购买商品明细表'
PARTITIONED BY (`dt` string)
stored as parquet
location '/warehouse/gmall/dws/dws_user_sale_detail_daycount/'
tblproperties ("parquet.compression"="snappy");
-- 导入数据
with
tmp_detail as
(
    select
        user_id,
        sku_id, 
        sum(sku_num) sku_num,   
        count(*) order_count, 
        -- order_price?
        sum(od.order_price*sku_num) order_amount
    from dwd_order_detail od
    where od.dt='2019-11-07'
    group by user_id, sku_id
)  
insert overwrite table dws_sale_detail_daycount partition(dt='2019-11-07')
select 
    tmp_detail.user_id,
    tmp_detail.sku_id,
    u.gender,
    -- 向上取整
    ceil(months_between('2019-11-07', u.birthday)/12)  age, 
    u.user_level,
    price,
    sku_name,
    tm_id,
    category3_id,
    category2_id,
    category1_id,
    category3_name,
    category2_name,
    category1_name,
    spu_id,
    tmp_detail.sku_num,
    tmp_detail.order_count,
    tmp_detail.order_amount 
from 
    tmp_detail 
    left join dwd_user_info u 
    on tmp_detail.user_id =u.id and u.dt='2019-11-07'
    left join dwd_sku_info s 
    on tmp_detail.sku_id =s.id and s.dt='2019-11-07'
;
