
采集并消费n天数据到HDFS
```sh
#!/bin/bash
n=$1
cluster 1
for ((i=0;i<n;i++));
do
    lg 0 100
    sleep 10s;
    # 修改日期字段
    dt 2019-08-28
    sleep 10s;
done
cluster 0
xcall sudo service ntpd restart
sleep 5s;
echo OK
