## 数仓集群搭建
### 安装虚拟机
安装vim tar rsync openssh openssh-clients libaio net-tools
CentOS7卸载mariadb

**关闭防火墙、配置host、免密连接、同步脚本**
```bash
yum install -y vim tar rsync openssh openssh-clients libaio net-tools ntp ntpdate ntp-doc
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

### 克隆虚拟机
```bash
vim /etc/udev/rules.d/70-persistent-net.rules
vim /etc/sysconfig/network-scripts/ifcfg-eth0
vim /etc/sysconfig/network #修改主机名
```
*配置多个节点之间的免密连接*

### 集群配置

-|hadoop102|hadoop103|hadoop104
:-:|:-|:-|:-
**HDFS**|NameNode<br>DataNode|DataNode|SecondaryNameNode<br>DataNode
**YARN**|NodeManager|ResourceManager<br>NodeManager|NodeManager

```bash
echo $JAVA_HOME
vim hadoop-env.sh
vim yarn-env.sh
vim mapred-env.sh

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
```
```xml
<!-- mapred-site.xml -->
<property>
	<name>mapreduce.framework.name</name>
	<value>yarn</value>
</property>
```

```
hadoop102
hadoop103
hadoop104
hadoop104
hadoop105
hadoop106
```
*该文件中添加的内容结尾不允许有空格，文件中不允许有空行。
集群同步slaves文件*

```bash
##配置历史服务器
vim mapred-site.xml
sbin/mr-jobhistory-daemon.sh start historyserver
##配置日志聚集
vim yarn-site.xml
```
```xml
<property>
<name>mapreduce.jobhistory.address</name>
<value>hadoop102:10020</value>
</property>
<property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>hadoop102:19888</value>
</property>
```
```xml
<property>
<name>yarn.log-aggregation-enable</name>
<value>true</value>
</property>

<property>
<name>yarn.log-aggregation.retain-seconds</name>
<value>604800</value>
</property>
```

*集群上分发配置*



### 群起集群

```bash
#第一次启动集群时需要格式化namenode
bin/hdfs namenode -format #102
#启动HDFS
sbin/start-dfs.sh #102
jps #103
#4166 NameNode
#4482 Jps
#4263 DataNode
jps #103
#3218 DataNode
#3288 Jps
jps #104
#3221 DataNode
#3283 SecondaryNameNode
#3364 Jps
#启动YARN
sbin/start-yarn.sh #103
```
[Web端查看SecondaryNameNode](http://hadoop104:50090/status.html).

[web端查看HDFS文件系统](http://tian:50070/dfshealth.html#tab-overview)

[Web页面查看YARN](http://hadoop103:8088/cluster)

[查看JobHistory](http://hadoop102:19888/jobhistory)

[Web查看日志](http://hadoop103:19888/jobhistory)

### 集群测试
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

### ZK安装配置

**安装部署**
```bash
tar -zxvf zookeeper-3.4.10.tar.gz -C /opt/module/
mv zoo_sample.cfg zoo.cfg #/opt/module/zookeeper-3.4.10/conf
### 配置服务器编号
# （1）在/opt/module/zookeeper-3.4.10/这个目录下创建zkData
mkdir -p zkData
# （2）在/opt/module/zookeeper-3.4.10/zkData目录下创建一个myid的文件
touch myid
# 添加myid文件，注意一定要在linux里面创建，在notepad++里面很可能乱码
# （3）编辑myid文件
vi myid
# 在文件中添加与server对应的编号：
# 2
# （4）拷贝配置好的zookeeper到其他机器上
xsync myid
# 并分别在hadoop102、hadoop103上修改myid文件中内容为3、4

### 配置zoo.cfg文件
# （1）重命名/opt/module/zookeeper-3.4.10/conf这个目录下的zoo_sample.cfg为zoo.cfg
mv zoo_sample.cfg zoo.cfg
# （2）打开zoo.cfg文件
vim zoo.cfg
# 修改数据存储路径配置
# dataDir=/opt/module/zookeeper-3.4.10/zkData
# 增加如下配置
#######################cluster##########################
# server.1=hadoop101:2888:3888
# server.2=hadoop102:2888:3888
# server.3=hadoop103:2888:3888
# （3）同步zoo.cfg配置文件
xsync zoo.cfg
# （4）配置参数解读
# server.A=B:C:D。
# A是一个数字，表示这个是第几号服务器
```
**启停测试**
```bash
#（1）启动Zookeeper
bin/zkServer.sh start

#（2）查看进程是否启动
jps
#4020 Jps
#4001 QuorumPeerMain

#（3）查看状态：
bin/zkServer.sh status
#ZooKeeper JMX enabled by default
#Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
#Mode: standalone

#（4）启动客户端：
bin/zkCli.sh

#（5）退出客户端：
quit #[zk: localhost:2181(CONNECTED) 0] 

#（6）停止Zookeeper
bin/zkServer.sh stop
```
### Flume安装配置
```bash
tar -zxvf apache-flume-1.7.0-bin.tar.gz -C ../module/
mv apache-flume-1.7.0-bin flume
mv flume-env.sh.template flume-env.sh
vim flume-env.sh
# export JAVA_HOME=/opt/module/jdk1.8.0_144
```
### Kafka安装配置
```bash
software]$ tar -zxvf kafka_2.11-0.11.0.0.tgz -C /opt/module/
mv kafka_2.11-0.11.0.0/ kafka
mkdir logs
cd config/
vim server.properties
vim /etc/profile # 添加kafka环境变量
source /etc/profile
xsync /opt/module/kafka/ # 分发后配置其他节点环境变量
# 修改其他节点server.properties中的brokerid为1和2
```
[server.properties](link/Kafka-server.properties)
**启停测试**
```bash
# 启动集群，先开zookeeper
kafka-server-start.sh -daemon config/server.properties # 在每个节点执行
# 关闭集群，先关zookeeper
kafka-server-stop.sh # 在每个节点执行
```



