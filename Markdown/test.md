#### Linux & Shell
```bash
find / -name "*.pid" # 搜索根目录下所有后缀为.pid的文件
df -h # 查看磁盘占用
free -h # 查看内存占用
tar -zxvf jdk.tar.gz # 解压文件
top # 实时显示系统状态
iotop # 实时显示磁盘IO状态
netstat -anp|grep 3306 # 查看端口号占用
cat /etc/issue # 查看当前系统版本
ps aux|grep yarn # 查看进程
ps -ef|grep yarn # 查看进程
awk '/^$/{print NR}' file1 # 查看file1里面空行所在行
awk -v sum=0 -F ""'{sum+=$2} END{print sum}' test.txt # 文件中指定列的和并输出
basename path # 获取每个文件的名称
ls -lR dirname|grep ".java$"|wc -l # 统计一个目录下包含.java文件的个数
```
```sql
-- 建表指定为外部表，指定表的location属性
create external table dim_city(...) location '/user/dim/dim_city';
-- 加载数据
load data local inpath '/home/dim_city.txt' into table dim_city;
```
```bash
if [-f file.txt];then
    echo "文件存在!"
else
    echo "文件不存在!"
fi
```

#### Hadoop阶段端口号汇总
50070   NameNode的http服务端口
9000    NameNode的接收rpc调用端口
8088    Yarn的http服务端口
10888   MapReduce运行历史手机服务的http服务端口
8042    NodeManager的http服务端口

#### HDFS读写流程
>**写流程**

1. 客户端创建一个分布式文件系统客户端对象，向NN发送上传文件的请求
2. NN验证请求合法后给客户端响应通知写操作
3. 客户端创建输出流，输出流写文件时，以块(128M)为单位，块由packet(64k)为基本单位，packet由多个chunk(512B+4B校验位)组成
4. 开始第一块的上传，请求NN，根据网络拓扑距离和上传的副本个数，分配指定数量的距离客户端最近的DN列表
5. 客户端请求最近的DN建立通道，DN列表中的DN依次建立通道，全部通道建立完成后开始传输，客户端将一块信息封装成一个packet，将packet放入消息队列，输出流在传输时，建立一个ack_queue存放消息队列date_queue要传输的packet
6. 客户端只负责当前packet发送给最近的DN，DN在收到packet后向客户端的流对象发送ack命令，当ack_queue中的所有packet已经被DN收到，当前队列删除该packet
7. 第一块数据上传完毕后会上报NN，当前块上传到了哪些DN，并按相同的方式上传第二块和后续所有块
8. 当所有数据上传完毕，关闭流等待NN响应

>**读流程**

1. 客户端向NN发送请求，请求读取指定路径文件
2. NN处理请求，返回当前文件的所有块列表信息
3. 客户端创建一个输出流，根据块的信息，从一块开始读取，根据拓扑距离选择最近一个节点读取，剩余块依次读取
4. 所有块信息读取完毕后关流

#### 2NN工作机制
1. 2NN和NN不是主从关系，2NN不是NN的热备，是两个不同的进程，2NN负责辅助NN工作，定期合并NN中的日志文件和镜像文件
2. 2NN基于两个触发条件执行checkpoint合并，每隔`dfs.namenode.checkpoint.period`秒合并一次，默认为1小时，每隔`dfs.namenode.checkpoint.txns`次合并一次，默认为100W，2NN默认每隔60秒向NN发送请求判断checkpoint的条件是否满足，如果满足向NN发送请求滚动日志，将历史日志和镜像文件拷贝到2NN工作目录中，加载到内存进行合并，合并后，将新的镜像文件发送给NN覆盖旧的镜像文件。

#### NN和2NN的区别和联系
>**联系**

1. 2NN需要NN配合工作，NN启动，2NN工作才有意义
2. 2NN可能会保存部分和NN一致的元数据，可以用来NN的容灾恢复

>**区别**

 * 是两个不同的进程，不是主从关系


#### 服役新节点和退役旧节点

1. 服役新节点:添加服务器、安装软件、配置环境、启动进程
2. 退役旧节点:使用黑名单和白名单

#### NN元数据损坏解决办法

1. 多目录配置
2. HA
3. 2NN

#### Hadoop序列化和反序列化


#### FileInputFormat切片机制



#### MapTask工作机制
>**Map阶段**
使用InputFormat的RecordReader读取切片中的每一对kv，每对kv都会调用map()

>**Sort阶段**
每对kv经过map()处理后输出，先进行分区，然后收集到缓冲区，当缓冲区到达溢写阀值80%时，对每个区的kv进行排序(快排)，然后溢写到磁盘，每次溢写都会合并成一个总的文件，该文件包含若干分区，每个区内数据有序

#### ReduceTask工作机制
>**copy阶段**
ReduceTask启动shuffle进程，到指定的maptask拷贝指定的数据，拷贝后合并成一个总文件

>**sort阶段**
在合并时，保证所有的数据合并后有序，会进行归并排序

>**reduce阶段**
合并后的文件进行分组，每一组数据调用reduce()，通过OutputFormat的RecordWriter将数据输出

#### Shuffle工作机制和Shuffle优化
map()结束到reduce()开始为shuffle阶段
sort copy sort
本质是减少磁盘IO和减少网络IO，即减少溢写次数和每次溢写的数据量以及网络传输量
>**MapTask阶段优化**
减少溢写次数，调大`mapreduce.task.io.sort.mn`和`mapreduce.map.sort.spill.percent`
减少合并次数，调大`io.sort.factor`
在合适的情况些使用Combiner对数据进行局部汇总
使用压缩，较少数据传输量

>**ReduceTask阶段优化**
reduce端减少溢写次数，调大`mapred.job.reduce.input.buffer.percent`

#### Combiner
1. combiner的作用是每次溢写数据到磁盘时，对数据局部合并，减少溢写数据量
2. 适用场景为求和、汇总等，不适用于平均数等互相有依赖关系的计算
3. 和reduce的唯一区别是combiner运行在MapTask的shuffle阶段，而reducer是在ReduceTask阶段


#### Hive sql
```sql
# 1
-- 简单建表语句
-- 2017/1/21
create table action(
    userId string,
    visitDate string,
    visitCount int
)
row format delimited fields terminated by '\t';
--统计出每个用户每月的累积访问次数
select 
    userId,
    date_format(convert(dt,getdate(),23),YYYY-mm) mn,
    sum(visitCount)
from action
group by userId,mn

# 2
-- 
create table visit(
    user_id string,
    shop string
)
row format delimited fields terminated by '\t';
-- 统计每个店铺访问次数top3的访客信息，输出店铺名称、访客id、访问次数
select shop,user_id,num,rank() over(partition by shop sort by num desc) rank
from(
    select shop,user_id,count(*) num
    from visit
    group by shop,user_id
)
where rank<=3
group by shop,user_id;


# 3
-- 数据样例，2017-01-01,10029028,1000003251,33.57
create table order_tab(
    dt string comment,
    order_id string,
    user_id string,
    amount decimal(10,2)
)
row format delimited fields terminated by '\t';

-- 2017年每个月的订单数、用户数、总成交金额
select mn,count(order_id),count(user_id),sum(amount)
select month(dt) mn,order_id,user_id,amount
from order_tab
group by mn;

-- 2017年11月的新客数(在11月才有第一笔订单)


with tmp as
-- 截至每个月总客户数
select mn,sum(count) over(order by mn rows between UNBOUNDED PRECEDING and current row) mn_asc_sum
from (
    select month(dt) mn,count(*) count
    from order_tab
    group by mn
)
select sum(sumA)-sum(sumB)
from(
    select sum11 sumA,0 sumB
    from tmp
    where mn=11
    union all
    select sum10 sumA,0 sumB
    where mn=10
)



# 5
/* 
日期 用户 年龄
11,test_1,23
11,test_2,19
11,test_3,39
11,test_1,23
11,test_3,39
11,test_1,23
12,test_2,19
13,test_1,23
15,test_2,19
16,test_2,19 */
create table user_age(
    dt string,
    user_id string,
    age int
)
row format delimited fields terminated by ',';

-- 求所有用户和活跃用户的总数及平均年龄(活跃用户指连续两天都有访问记录的用户)
with tmp as(
    select count(*) count,avg(2019-year(dt)) age_avg
    from user_age
    group by user_id
)

-- 活跃用户总数
select tmp.count,count(*),tmp.age_avg
from(
    select user_id
    from(
        select user_id,date_sub(dt,rank) diff
        from(
            select user_id,dt,rank() over(partition by user_Id order by dt) rank
            from user_age   
            ) t1
        group by user_id,diff
        having count(*)>1
        )
    -- 去重
    group by user_id
    )



# 7
-- 图书管理数据库
-- 建表，图书、读者、借阅


-- 找出姓李的读者姓名(NAME)和所在单位(COMPANY)


-- 查找“高等教育出版社”的所有图书名称（BOOK_NAME）及单价（PRICE），结果按单价降序排序


-- 查找价格介于10元和20元之间的图书种类(SORT）出版单位（OUTPUT）和单价（PRICE），结果按出版单位（OUTPUT）和单价（PRICE）升序排序。



-- 查找所有借了书的读者的姓名（NAME）及所在单位（COMPANY）。



-- 求”科学出版社”图书的最高单价、最低单价、平均单价



-- 找出当前至少借阅了2本图书（大于等于2本）的读者姓名及其所在单位




-- 考虑到数据安全的需要，需定时将“借阅记录”中数据进行备份，请使用一条SQL语句，在备份用户bak下创建与“借阅记录”表结构完全一致的数据表BORROW_LOG_BAK.井且将“借阅记录”中现有数据全部复制到BORROW_1.0G_ BAK中



-- 现在需要将原Oracle数据库中数据迁移至Hive仓库，请写出“图书”在Hive中的建表语句（Hive实现，提示：列分隔符|；数据表数据需要外部导入：分区分别以month＿part、day＿part 命名）



-- Hive中有表A，现在需要将表A的月分区　201505　中　user＿id为20000的user＿dinner字段更新为bonc8920，其他用户user＿dinner字段数据不变，请列出更新的方法步骤。（Hive实现，提示：Hlive中无update语法，请通过其他办法进行数据更新）



# 9
-- 
CREATE TABLE `credit_log` 
(
    `dist_id` int（11）DEFAULT NULL COMMENT '区组id',
    `account` varchar（100）DEFAULT NULL COMMENT '账号',
    `money` int(11) DEFAULT NULL COMMENT '充值金额',
    `create_time` datetime DEFAULT NULL COMMENT '订单时间'
)ENGINE=InnoDB DEFAUILT CHARSET-utf8;

-- 请写出SQL语句，查询充值日志表2015年7月9号每个区组下充值额最大的账号，要求结果：区组id，账号，金额，充值时间
select
   *
from
   credit_log t1
where
(
    select
       count(*)
    from
       credit_log t2
    where	
       t1.dist_id=t2.dist_id
       and
       t1.money>t2.money
)>2;

# 10
CREATE TABIE `account` 
(
    `dist_id` int（11）
    DEFAULT NULL COMMENT '区组id'，
    `account` varchar（100）DEFAULT NULL COMMENT '账号' ,
    `gold` int（11）DEFAULT NULL COMMENT '金币' 
    PRIMARY KEY （`dist_id`，`account_id`），
）ENGINE=InnoDB DEFAULT CHARSET-utf8;
-- 查询各自区组的money排行前十的账号(分组取前十)
select
   *
from
   account t1
where
(
    select
       count(*)
    from
       account t2
    where	
       t1.dist_id=t2.dist_id
       and
       t1. gold >t2. gold
)>10;


# 12
create table student
(
	id bigint comment ‘学号’，
	name string comment ‘姓名’,
	age bigint comment ‘年龄’
);
create table course
(
	cid string comment ‘课程号，001/002格式’,
	cname string comment ‘课程名’
);
Create table score
(
	Id bigint comment ‘学号’,
	cid string comment ‘课程号’,
	score bigint comment ‘成绩’
) partitioned by(event_day string);
/* 1）请将本地文件（/home/users/test/20190301.csv）文件，加载到分区表score的20190301分区中，并覆盖之前的数据
2）查出平均成绩大于60分的学生的姓名、年龄、平均成绩
3）查出没有‘001’课程成绩的学生的姓名、年龄
4）查出有‘001’\’002’这两门课程下，成绩排名前3的学生的姓名、年龄
5）创建新的表score_20190317，并存入score表中20190317分区的数据
6）如果上面的score表中，uid存在数据倾斜，请进行优化，查出在20190101-20190317中，学生的姓名、年龄、课程、课程的平均成绩
7）描述一下union和union all的区别，以及在mysql和HQL中用法的不同之处？
8）简单描述一下lateral view语法在HQL中的应用场景，并写一个HQL实例 */


# 13
create external table order(
    id int,
    user_id string,
    city string,
    order_time string
)
row format delimited fields terminated by '\t';
create external table user(
    user_id string,
    user_name string
)
row format delimited fields terminated by '\t';

-- 分别求出每个城市2018年1月、2月、3月订单数

-- 查找用户的最后一次购买时间及其城市

-- 计算用户画像，用户在那个城市下单次数最多就属于哪个城市，如果对多的城市有多个，取最多的城市中下单时间最大的哪个作为用户所在城市，user_id,city
```

#### MR的job提交流程


#### Hadoop调度器







