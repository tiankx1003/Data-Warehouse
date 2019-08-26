## Data-Warehouse Cluster Build
### Install CentOS
**关闭防火墙、配置host、免密连接、同步脚本**
```bash
yum install -y vim tar rsync openssh openssh-clients libaio nc net-tools ntp ntpdate ntp-doc
# 新建用户授权
passwd root
useradd tian
passwd tian
vim /etc/sudoer
# tian ALL=(ALL)    NOPASSWD:ALL
#设置IP 主机名 hosts 关闭防火墙 
service iptables status
service iptables stop
chkconfig iptables --list
chkconfig iptables off
vim /etc/vimrc # 修改vim配置
vim /etc/hosts
# 免密连接 同步脚本
cd ~/bin
vim xsync
vim copy-ssh
vim ~/.bashrc # source /etc/profile
# 安装软件配置环境变量
chown tian:tian /opt/module/ /opt/software -R
```
```powershell
scp id_rsa.pub tian@hadoop101:/home/tian/.ssh
```
```bash
#上传本地端公钥(root & tian)
ssh-copy-id hadoop101
cat id_rsa.pub >> authorized_keys
```

### Clone System
```bash
vim /etc/udev/rules.d/70-persistent-net.rules
vim /etc/sysconfig/network-scripts/ifcfg-eth0
vim /etc/sysconfig/network #修改主机名
```
*配置多个节点之间的免密连接*

### Hadoop

-|hadoop102|hadoop103|hadoop104
:-:|:-|:-|:-
**HDFS**|NameNode<br>DataNode|DataNode|SecondaryNameNode<br>DataNode
**YARN**|NodeManager|ResourceManager<br>NodeManager|NodeManager

```bash
vim core-site.xml
vim hdfs-site.xml
vi yarn-site.xml 
cp mapred-site.xml.template mapred-site.xml
vim mapred-site.xml

vim /opt/module/hadoop-2.7.2/etc/hadoop/slaves
```

```xml
<!-- core-site.xml -->
<property>
	<name>fs.defaultFS</name>
	<value>hdfs://hadoop102:9000</value>
</property>
<property>
	<name>hadoop.tmp.dir</name>
	<value>/opt/module/hadoop-2.7.2/data/tmp</value>
</property>
```
```xml
<!-- hdfs-site.xml -->
<property>
	<name>dfs.replication</name>
	<value>3</value>
</property>
<property>
	<name>dfs.namenode.secondary.http-address</name>
	<value>hadoop104:50090</value>
</property>
```
```xml
<!-- yarn-site.xml  -->
<property>
	<name>yarn.nodemanager.aux-services</name>
	<value>mapreduce_shuffle</value>
</property>
<property>
	<name>yarn.resourcemanager.hostname</name>
	<value>hadoop103</value>
</property>
<!-- 配置日志聚集 -->
<property>
	<name>yarn.log-aggregation-enable</name>
	<value>true</value>
</property>
<property>
	<name>yarn.log-aggregation.retain-seconds</name>
	<value>604800</value>
</property>
```
```xml
<!-- mapred-site.xml -->
<property>
	<name>mapreduce.framework.name</name>
	<value>yarn</value>
</property>
<!-- 配置历史服务器 -->
<property>
	<name>mapreduce.jobhistory.address</name>
	<value>hadoop102:10020</value>
</property>
<property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>hadoop102:19888</value>
</property>
```

```
hadoop102
hadoop103
hadoop104
```
* 该文件中添加的内容结尾不允许有空格，文件中不允许有空行
* 集群上分发配置

**群起集群**

```bash
#第一次启动集群时需要格式化namenode
bin/hdfs namenode -format #102
#启动HDFS
sbin/start-dfs.sh #102
#启动历史服务器
sbin/mr-jobhistory-daemon.sh start historyserver
#启动YARN
sbin/start-yarn.sh #103
jpsall #查看所有进程
```
[Web端查看SecondaryNameNode](http://hadoop104:50090/status.html).
[web端查看HDFS文件系统](http://tian:50070/dfshealth.html#tab-overview)
[Web页面查看YARN](http://hadoop103:8088/cluster)
[查看JobHistory](http://hadoop102:19888/jobhistory)
[Web查看日志](http://hadoop103:19888/jobhistory)

**集群测试**
```bash
#hadoop fs -mkdir -p /user/tian/input
hdfs dfs -mkdir -p /usrer/tian/input1
hdfs dfs -put wcinput/wc.input /user/tian/input1
#wordcount
hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.2.jar wordcount /user/tian/input1/ /user/tian/output1
hdfs dfs -cat /user/tian/input1/wc.input
hdfs dfs -get /user/tian/input1/wc.input ./output
hdfs dfs -rm /user/tian/input1/wc.input

hadoop fs -put /opt/software/hadoop-2.7.2.tar.gz  /user/tian/input2
#/opt/module/hadoop-2.7.2/data/tmp/dfs/data/current/BP-938951106-192.168.10.107-1495462844069/current/finalized/subdir0/subdir0
#查看HDFS在磁盘存储文件内容
cat blk_1073741835
cat blk_1073741836>>tmp.file
cat blk_1073741837>>tmp.file
tar -zxvf tmp.file
```

### ZooKeeper

**安装部署**
```bash
tar -zxvf zookeeper-3.4.10.tar.gz -C /opt/module/
### 配置服务器编号
mkdir -p zkData
vi myid # 在文件中添加与server对应的编号：
xsync myid # 并分别在hadoop102、hadoop103上修改myid
mv zoo_sample.cfg zoo.cfg
vim zoo.cfg
xsync zoo.cfg
```
```conf
# 修改数据存储路径配置
dataDir=/opt/module/zookeeper/zkData
# 增加如下配置
#######################cluster##########################
server.1=hadoop102:2888:3888
server.2=hadoop103:2888:3888
server.3=hadoop104:2888:3888
```

**启停测试**
```bash
bin/zkServer.sh start
jps
# QuorumPeerMain
bin/zkServer.sh status
bin/zkCli.sh
quit
bin/zkServer.sh stop
```

### Flume
```bash
tar -zxvf apache-flume-1.7.0-bin.tar.gz -C ../module/
mv apache-flume-1.7.0-bin flume
mv flume-env.sh.template flume-env.sh
vim flume-env.sh
# export JAVA_HOME=/opt/module/jdk1.8.0_144
```
### Kafka
```bash
software]$ tar -zxvf kafka_2.11-0.11.0.0.tgz -C /opt/module/
mv kafka_2.11-0.11.0.0/ kafka
mkdir logs
cd config/
vim server.properties
xsync /opt/module/kafka/ # 分发后配置其他节点环境变量
# 修改其他节点server.properties中的brokerid为1和2
```
[server.properties](Kafka-server.properties)

**启停测试**
```bash
# 启动集群，先开zookeeper
kafka-server-start.sh -daemon config/server.properties # 在每个节点执行
# 关闭集群，先关zookeeper
kafka-server-stop.sh # 在每个节点执行
```

### HBase

```bash
# 启动zk hadoop
tar -zxvf hbase-1.3.1-bin.tar.gz -C /opt/module
vim hbase-env.sh
vim hbase-site.xml
vim regionservers
mv hbase-1.3.1/ hbase/
# 软链接hadoop配置文件到hbase,每个节点配置了hadoop环境变量可以省略这一步
ln -s /opt/module/hadoop-2.7.2/etc/hadoop/core-site.xml /opt/module/hbase/conf/core-site.xml
ln -s /opt/module/hadoop-2.7.2/etc/hadoop/hdfs-site.xml /opt/module/hbase/conf/hdfs-site.xml
xsync /opt/module/hbase/ # 分发配置
# 启停
hbase-daemon.sh start master
hbase-daemon.sh start regionserver
start-hbase.sh # 启动方法二
stop-hbase.sh
hbase shell # 启动交互
```

```properties
export JAVA_HOME=/opt/module/jdk1.8.0_144
export HBASE_MANAGES_ZK=false
```

```xml
<configuration>
	<property>     
		<name>hbase.rootdir</name>     
		<value>hdfs://hadoop102:9000/hbase</value>   
	</property>

	<property>   
		<name>hbase.cluster.distributed</name>
		<value>true</value>
	</property>

   <!-- 0.98后的新变动，之前版本没有.port,默认端口为60000 -->
	<property>
		<name>hbase.master.port</name>
		<value>16000</value>
	</property>

	<property>   
		<name>hbase.zookeeper.quorum</name>
	     <value>hadoop102,hadoop103,hadoop104</value>
	</property>

	<property>   
		<name>hbase.zookeeper.property.dataDir</name>
	     <value>/opt/module/zookeeper-3.4.10/zkData</value>
	</property>
</configuration>
```

```
hadoop102
hadoop103
hadoop104
```

[hbase页面](http://hadoop102:16010)

### MySQL
```bash
rpm -qa|grep mysql #查看当前mysql的安装情况
sudo rpm -e --nodeps mysql-libs-5.1.73-7.el6.x86_64 #卸载之前的mysql
sudo rpm -ivh MySQL-client-5.5.54-1.linux2.6.x86_64.rpm #在包所在的目录中安装
sudo rpm -ivh MySQL-server-5.5.54-1.linux2.6.x86_64.rpm
mysqladmin --version #查看mysql版本
rpm -qa|grep MySQL #查看mysql是否安装完成
sudo service mysql restart # 重启服务
mysqladmin -u root password #设置密码,需要先启动服务
```
```sql
# 修改密码
SET PASSWORD=PASSWORD('root');
## MySQL在user表中主机配置
show databases;
use mysql;
show tables;
desc user;
select User, Host, Password from user;
# 修改user表，把Host表内容修改为%
update user set host='%' where host='localhost';
# 删除root中的其他账户
delete from user where Host='hadoop102';
delete from user where Host='127.0.0.1';
delete from user where Host='::1';
# 刷新
flush privileges;
\q;
```
### MySQL HA
<!-- TODO 添加MySQL HA内容 -->
### Hive
```bash
tar -zxvf apache-hive-1.2.1-bin.tar.gz -C /opt/module/
mv apache-hive-1.2.1-bin/ hive
mv hive-env.sh.template hive-env.sh
# export HADOOP_HOME=/opt/module/hadoop-2.7.2
# export HIVE_CONF_DIR=/opt/module/hive/conf

# 在HDFS上创建/tmp和/user/hive/warehouse两个目录并修改他们的同组权限可写
bin/hadoop fs -mkdir /tmp
bin/hadoop fs -mkdir -p /user/hive/warehouse
bin/hadoop fs -chmod g+w /tmp
bin/hadoop fs -chmod g+w /user/hive/warehouse
```

**Hive元数据配置到MySQL**

```bash
# 拷贝驱动
tar -zxvf mysql-connector-java-5.1.27.tar.gz
cp mysql-connector-java-5.1.27-bin.jar /opt/module/hive/lib/
```
```bash
# 配置Metastore到MySQL
# /opt/module/hive/conf目录下创建一个hive-site.xml
touch hive-site.xml
vi hive-site.xml
```

根据官方文档配置参数
[官方文档参数](https://cwiki.apache.org/confluence/display/Hive/AdminManual+MetastoreAdmin)
[**hive-site.xml**](../../Configuration/Hive/hive-site.xml)

```bash
hiveserver2
beeline
# !connect jdbc:hive2://hadoop102:10000
```

### Tez
```bash
tar -zxvf apache-tez-0.9.1-bin.tar.gz /opt/module/
mv apache-tez-0.9.1-bin/ tez-0.9.1
# Hive配置Tez
vim hive-env.sh
vim hive-site.xml
```
```conf
# Set HADOOP_HOME to point to a specific hadoop install directory
export HADOOP_HOME=/opt/module/hadoop-2.7.2

# Hive Configuration Directory can be controlled by:
export HIVE_CONF_DIR=/opt/module/hive/conf

# Folder containing extra libraries required for hive compilation/execution can be controlled by:
export TEZ_HOME=/opt/module/tez-0.9.1    #是你的tez的解压目录
export TEZ_JARS=""
for jar in `ls $TEZ_HOME |grep jar`; do
    export TEZ_JARS=$TEZ_JARS:$TEZ_HOME/$jar
done
for jar in `ls $TEZ_HOME/lib`; do
    export TEZ_JARS=$TEZ_JARS:$TEZ_HOME/lib/$jar
done

export HIVE_AUX_JARS_PATH=/opt/module/hadoop-2.7.2/share/hadoop/common/hadoop-lzo-0.4.20.jar$TEZ_JARS
```
```xml
	<property>
		<name>hive.execution.engine</name>
		<value>tez</value>
	</property>
```
/opt/module/hive/conf目录下添加[**tez-site.xml**](../../Configuration/tez-site.xml)
```bash
# 上传tez到HDFS
hadoop fs -mkdir /tez
hadoop fs -put /opt/module/tez-0.9.1/ /tez
hadoop fs -ls /tez /tez/tez-0.9.1
# 启动hive测试
hive
```
```sql
create table student(
id int,
name string);
insert into student values(1,"lisi");
select * from student;
```