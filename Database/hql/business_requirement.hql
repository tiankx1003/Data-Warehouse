-- gmv成交总额
  -- 建表
drop table if exists ads_gmv_sum_day;
create external table ads_gmv_sum_day(
    dt string comment '统计日期',
    gmv_count bigint comment '当日gmv订单个数',
    gmv_amount decimal(16,2) comment '当日gmv订单总金额',
    gmv_payment decimal(16,2) comment '当日支付金额'
) comment '当日gmv信息'
row format delimited fields terminated by '\t'
location 'warehouse/gmall/ads/ads_gmv_sum/day';

  -- 插入数据
insert into table ads_gmv_sum_day
select 
    '2019-08-28' dt,
    sum(order_count) gmv_count,
    sum(order_mount) gmv_mount,
    sum(payment_mount) gmv_payment
from dws_user_action
group by dt;

-- 用户新鲜度，新增用户占日活用户的比例
  -- 建表
drop table if exists ads_user_convert_day;
create external table ads_user_convert_day(
    dt string comment '统计日期',
    uv_m_count bigint comment '当日活跃设备数',
    new_m_count bigint comment '当日新增设备数',
    new_m_ratio decimal(10,2) '用户新鲜度'
) comment '转化率，用户新鲜度'
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_user_convert_day';

  -- 插入数据
insert into table ads_user_convert_day
select 
    '2019-08-28' dt,
    sum(t1.dc) uv_m_count,
    sum(t1.nmc) new_m_count,
    cast(sum(t1.dc)/sum(t1.nmc)*100 as decimal(10,2)) new_m_ratio
from
    (
        select day_count dc,0 nmc
        from ads_uv_count
        where dt='2019-08-28'
        union all
        select 0 dc,new_mid_count nmc
        from ads_new_mid count
        where create_date='2019-08-28'
    ) t1;
    

-- 用户行为漏斗分析，访问->下单->付款 转化率
  -- 建表
drop table if exists ads_user_action_convert_day;
create external table ads_user_action_convert_day(
    dt string comment '统计日期',
    total_visitor_m_count bigint comment '总访问人数',
    order_u_count bigint comment '总下单人数',
    visitor2order_convert_ratio decimal(10,2) comment '访问到下单转化率',
    payment_u_count bigint comment '支付人数'
    order2payment_convert_ratio decimal(10,2) comment '下单到付款转化率' 
) comment '用户行为漏斗分析'
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_user_action_convert_day';

  -- 插入数据
insert into table ads_user_action_convert_day
select
	dt,
	uc.day_count total_visitor_m_count,
	t1.s_oc order_u_count,
	cast(t1.s_oc/uc.day_count as decimal(10,2)) visitor2order_convert_ratio,
	t1.s_pc payment_u_count,
	cast(t1.s_pc/t1.s_oc as decimal(10,2)) order2payment_convert_ratio
from
	(
		select 
			dt,
			sum(if(order_count)>0,1,0) s_oc,
			sum(if(payment_count)>0,1,0) s_pc,
		from ads_user_action
		where dt='2019-08-28',
		group by dt
	) t1
	join ads_uv_count uc
	on t1.dt=uc.dt;


-- 品牌复购率
  -- DWS - 用户购买商品明细表(宽表)
drop table if exists dws_sale_detail_daycount;
create external table dws_sal_detail_daycount(
	user_id string comment '用户id',
	sku_id string comment '商品id',
	user_gender string comment '用户性别',
	user_age string comment '用户年龄',
	user_level string comment '用户等级',
	order_price decimal(10,2) comment '商品价格',
	sku_name string comment '商品名称',
	sku_tm_id string comment '品牌id',
	sku_category3_id string comment '商品三级品类id',
	sku_category2_id string comment '商品二级品类id',
	sku_category1_id string comment '商品一级品类id',
	sku_category3_name string comment '商品三级品类名称',
	sku_category2_name string comment '商品二级品类名称',
	sku_category1_name string comment '商品一级品类名称',
	spu_id string comment '购买个数',
	order_count string comment '当日下单单数',
	order_amount string comment '当日下单金额'
) comment '用户购买商品明细表'
partitioned by (dt string)
stored as parquet
location '/warehouse/gmall/dws/dws_user_sale_detail_daycount/'
tblproperties("parquet.compression"="snappy");



  -- ADS - 品牌复购率