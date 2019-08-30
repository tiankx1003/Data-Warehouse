# Data-Warehouse
* 一个应用了Hadoop生态体系阶段相关技术的大数据离线计算案例。

## 目录介绍
| Directory                | Description                                |
| :----------------------- | :----------------------------------------- |
| ~~**Hello**~~            | 用于测试分支  **已过期*                    |
| **logcollector**         | 用于生成数据的Maven工程                    |
| **Configuration**        | 配置文件                                   |
| **Configuration/Flume**  | Flume任务的`*.conf`配置文件                |
| **Configuration/Hadoop** | `$HADOOP_HOME/etc/hadoop/`目录下的配置文件 |
| **gmv-job**              | gmv任务<!-- 添加描述 -->                   |
| **Markdown**             | 数据仓库各个阶段的的技术文档               |
| **ShellScript**          | 服务器端的自定义脚本文件，主要用于启停进程 |
| **flumeinterceptor**     | Flume自定义拦截器                          |
| **xmind**                | 脑图                                       |

## 完成进度

#### ▼ 用户行为数据采集阶段

>**架构设计**<br>项目需求分析<br>系统流程设计<br>技术选型<br>服务器选型<br>集群规划<br>

>**数据生成脚本**<br>事件日志bean<br>启动日志bean<br>主程序<br>

>**环境搭建**<br>JDK配置<br>Hadoop集群搭建<br>HDFS存储多目录<br>支持LZO压缩配置<br>基准测试<br>Hadoop参数优化<br>Zookeeper配置<br>`/.bashrc`配置<br>Flume配置<br>生成日志<br>Kafka配置<br>采集日志Flume<br>Flume消费Kafka配置<br>采集通道启停<br>

#### ▼ 用户行为数据仓库

>**数仓分层**<br>Hive配置Tez引擎<br>ODS<br>DWD

>**业务需求**<br>用户活跃主题<br>用户新增主题<br>用户留存主题<br>沉默用户数<br>本周回流用户数<br>流失用户数<br>最近连续三周活跃用户数<br>最近七天内连续三天活跃用户数<br>

#### ▼ 系统业务数据仓库
>**业务知识与数据结构**<br>业务流程<br>电商常识<br>表的结构<br>

>**数仓理论**<br>表的分类<br>同步策略<br>范式理论<br>关系建模、维度建模<br>雪花模型、星型模型、星座模型<br>

>**数仓搭建**<br>Hadoop支持Snappy压缩<br>Sqoop业务数据导入数仓<br>ODS<br>DWD<br>DWS行为宽表<br>

>**业务需求**<br>GMV成交总额<br>用户新鲜度和漏斗分析<br>品牌复购率

>**其他内容**<br>数据可视化<br>Azkaban<br>拉链表<br>

#### ▼ 即席查询
>**Presto**

>**Druid**

>**Kylin**

#### ▼ CDH版数仓采集
 * 略

<p align="right"><i>▲2019-8-30 14:57:09</i></p>

