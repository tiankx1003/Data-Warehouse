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

  -- 插入数据
	-- 临时表,通过订单详情表得到指定日期每个人的用户编号和每个商品的、商品编号、商品数量、订单数、下单金额
insert into table dws_sale_detail_daycount
with tmp_detail
as(
	select
		user_id,
		sku_id,
		sum(sku_num) sku_num,
		count(*) order_count,
		sum(od.order_price*sku_num) order_amount
	from dwd_order_detail od
	where od.dt='2019-08-28'
	group by user_id, sku_id
)
select
    td.user_id,
    td.sku_id,
    ui.gender,
    -- ui.age,
    ceil(month_between('2019-08-28',ui.birthday)/12),
    ui.level,
    si.price,
    si.name,
    si.tm_id,
    si.category3_id,
    si.category2_id,
    si.category1_id,
    si.category3_name,
    si.category2_name,
    si.category1_name,
    si.spu_id,
    td.sku_num,
    td.order_count,
    td.order_amount
from
    tmp_detail td
    left join dwd_user_info ui
    on td.user_id=ui.id and dt='2019-08-28'
    left join dwd_sku_info si
    on td.sku_id=si.id and dt='2019-08-28';

  -- ADS - 品牌复购率
  -- 建表
drop table if exists ads_sale_tm_category1_stat_mn;
create external table ads_sale_tm_category1_stat_mn(
	tm_id string comment '品牌id',
	category1_id string comment '1级品类编号',
	category1_name string comment '1级品类名称',
	buycount bigint comment '购买人数',
	buy_twice_last bigint comment '两次以上购买人数',
	buy_twice_last_ratio bigint comment '单次复购率',
	buy_3times_last bigint comment '三次以上购买人数',
	buy_3times_last_ratio decimal(10,2) comment '多次复购率',
	stat_mn string comment '统计月份',
	stat_date string comment '统计日期'
) comment '复购率统计'
row format delimited fields terminated by '\t'
location '/warehouse/gmail/ads/ads_sale_tm_category1_stat_mn';

  -- 插入数据
insert into table ads_stat_tm_category1_stat_mn
select
	mn.sku_tm_id,
	mn.category1_id,
	mn.category1_name,
	sum(if(mn.order_count>1,1,0)) buycount,
	sum(if(mn.order_count>2,1,0)) buy_twice_last,
	cast(sum(if(mn.order_count>2,1,0))/sum(if(mn.order_count>1,1,0))as decimal(10,2)) buy_twice_last_ratio,
	sum(if(mn.order_count>3,1,0)) buy_3times_last,
	cast(sum(if(mn.order_count>3,1,0))/sum(if(mn.order_count>1,1,0))as decimal(10,2)) buy_3times_last_ratio,
	date_format('2019-08-28','yyyy-MM') stat_mn,
	'2019-08-28' stat_date
from
	(
		select
			user_id,
			sd.sku_tm_id,
			sd.sku_category1_id,
			sd.sku_category1_name
			sum(order_count) order_count
		from dws_sale_detail_daycount sd
		where date_format(dt,'yyyy-MM')=date_format('2019-08-28','yyyy-MM')
		group by user_id, sd.sku_tm_id, sd.sku_category1_id, sd.sku_category1_name
	) mn
group by mn.sku_tm_id, mn.sku_category1_id, mn.sku_category1_name;

-- 每个等级的用户对应的复购率前十的商品排行
  -- 建表语句
drop table if exists ads_rebuy_ratio_sku_top10(
	user_level string '用户等级',
	sku_id string '商品id',
	rebuy_ratio decimal(10,2) comment '复购率',
	rank_num int comment '排名'
) comment '每个等级的用户对应的复购率前十的商品排行'
row format delimited fields terminated by '\t'
location '/warehouse/gmall/ads/ads_reuy_ratio_sku_top10';

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