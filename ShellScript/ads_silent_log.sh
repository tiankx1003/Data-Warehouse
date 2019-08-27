#!/bin/bash

hive=/opt/module/hive/bin/hive
APP=gmall

if [ -n "$1" ];then
	do_date=$1
else
	do_date=`date -d "-1 day" +%F`
fi

echo "-----------导入日期$do_date-----------"

sql="
insert into table "$APP".ads_silent_count
select 
    '$do_date' dt,
    count(*) silent_count
from 
(
    select 
        mid_id
    from "$APP".dws_uv_detail_day
    where dt<='$do_date'
    group by mid_id
    having count(*)=1 and min(dt)<=date_add('$do_date',-7)
)t1;"

$hive -e "$sql"
