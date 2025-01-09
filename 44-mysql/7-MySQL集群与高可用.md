# MySQL 集群

## 集群介绍

当一个系统，或一个服务的请求量达到一定的数量级的时候，后端的数据库服务，很容易成为其性能瓶 颈。除了性能问题之外，如果只部署单个数据库服务，在此数据库服务当机，不能提供服务的情况下，整个系 统都会不可用。

服务性能扩展的两个方向: 横向 和 纵向

*   横向扩展：
    *   一 般采用新增节点的方式，增加服务节点的规模来解决性能问题，比如，当一台机器不够用时，可以再增加一台 机器或几台机器来分担流量和业务
*   纵向扩展：
    *   一般采 用升级服务器硬件，增加资源供给，修改服务配置项等方式来解决性能问题，比如，将服务器由32G内存升级 成128G内存，将服务最大并发数由128调整到256等。

## MySQL 主从复制

在实际生产环境中，为了解决 MySQL 服务的单点和性能问题，使用 MySQL 主从复制架构是非常常见的一种 方案。

在主从复制架构中，将 MySQL 服务器分为主服务器(Master)和从服务器(Slave)两种角色，主**服务器 负责数据写入(insert，update，delete，create 等)，从服务器负责提供查询服务(select 等)。**

MySQL 主从架构属于向外扩展方案，主从节点都有相同的数据集，其基于二进制日志的单向复制来实 现，复制过程是一个异步的过程。

**主从复制的优点**

*   负载均衡读操作：将读操作进行分流，由另外一台或多台服务器提供查询服务，降低 MySQL 负载，提升响 应速度
*   数据库备份：主从节点上都有相同的数据集，从而也实现了数据库的备份
*   高可用和故障切换：主从架构由两个或多个服务节点构成，在某个节点不可用的情况下，可以进行转移和切 换，保证服务可用
*    MySQL升级：当 MySQL 服务需要升级时，由于主从架构中有多个节点，可以逐一升级，而不停止服务

**主从复制的缺点**

*   数据延时：主节点上的数据需要经过复制之后才能同步到从节点上，这个过程需要时间，从而会造成主从节 点之间的数据不一致
*   性能消耗：主从复制需要开启单独线程，会消耗一定资源
*   数据不对齐：如果主从复制服务终止，而且又没有第一时间恢复，则从节点的数据一直无法更新



依赖于 MySQL 服务的应用程序连接代理，代理将应用程序的写操作分发到 Master 节点，将读操作分 发到从节点，如果有多个从节点，还可以根据不同的调度算法来进行分发。

![image-20250107192754370](pic/image-20250107192754370.png)

## 主从复制原理

主从同步之前，两者的数据库软件版本、基准数据都是一样的。

在从库上启动复制时，首先创建I/O线程去连接主库，主库随后创建Binlog Dump线程读取数据库特定 事件并发送给I/O线程，I/O线程获取到事件数据后更新到从库的中继日志Relay Log中去，之后从库上的 SQL线程读取中继日志Relay Log中更新的数据库事件并应用

三个线程

| **线程**               | **节点** | **作用**                                                     |
| ---------------------- | -------- | ------------------------------------------------------------ |
| **Binlog Dump Thread** | Master   | 为 Slave 节点的 I/O Thread 提供本机的 binlog（二进制日志）数据，传输到从节点。 |
| **I/O Thread**         | Slave    | 从 Master 节点获取 binlog 数据，并存放到本地的 relay log（中继日志）中。 |
| **SQL Thread**         | Slave    | 从 relay log 中读取日志内容，将数据重放到本地数据库中，完成同步操作。 |

两个日志

| **日志类型**  | **节点** | **作用**                                                     |
| ------------- | -------- | ------------------------------------------------------------ |
| **Binlog**    | Master   | 主节点的二进制日志，记录所有更改数据的事务或事件，为从节点提供同步数据的源。 |
| **Relay Log** | Slave    | 从主节点同步过来的中继日志，暂存于从节点，用于 SQL Thread 解析并重放到从节点的数据文件中。 |

相关文件

```shell
master.info  # 用于保存slave连接至master时的相关信息，例如账号、密码、服务器地址              

relay-log.info  # 保存在当前slave节点上已经复制的当前二进制日志和本地relay log日志的对应关系         

mysql-relay-bin.00000N # 中继日志,保存从主节点复制过来的二进制日志,本质就是二进制日志     

# MySQL8.0 取消 master.info 和 relay-log.info文件
# 在MySQL 8.0中，复制配置和状态信息不再直接存储在磁盘上的master.info和relay-log.info文件中。
# 相反，这些信息被存储在数据字典表（如mysql.slave_master_info和mysql.slave_relay_log_info）中。
# 这些表提供了与旧文件相同的信息，但具有更好的性能和可靠性，因为它们是由MySQL服务器直接管理的。
```

![image-20250107193127311](pic/image-20250107193127311.png)

*   Master 节点
    *   为每一个 Slave 节点上的 I/O thread 启动一个 dump thread，用来向其提供本机 的二进制事件
*   Slave 节点
    *   I/O thread 线程向 Master 节点请求该节点上的二进制事件，并将得到的内容写到当前 节点上的 replay log 中
    *   SQL thread 实时监测 replay log 内容是否有更新，如果更新，则将该文件中的内容 解析成SQL语句，还原到 Slave 节点上的数据库中去，这样来保证主从节点之间的数据同步。

## 主从复制配置

### 主库配置

参考文档

*   mysql8.0 
    *   https://dev.mysql.com/doc/refman/8.0/en/replication-configuration.html       

*   #mysql5.7 
    *   https://dev.mysql.com/doc/refman/5.7/en/replication-configuration.html       

*   mariadb
    *   https://mariadb.com/kb/en/setting-up-replication/  



**配置文件**

```ini
[mysqld]
# 启用二进制日志，指定路径与文件前缀
log_bin=/data/logbin/mysql-bin  
# 1 to 4294967295，默认值为1，主节点为0，则拒绝所有从节点的连接。
# 通常唯一id写主机ip的最后一位
server-id=N						

```

**创建有复制权限的用户账号**

```sql
create user repluser@'10.0.0.%' identified by '123456';
grant replication slave on *.* to repluser@'10.0.0.%';
```



### 从库配置

参考文档

https://dev.mysql.com/doc/refman/8.0/en/change-master-to.html  

**配置文件**

```ini
[mysqld]
# 开启从节点二进制日志
log-bin
# 为当前节点设置一个全局唯一的ID号,从节点为0，所有master都将拒绝此slave的连接
server_id=N 
# 设置数据库只读，针对supper user无效
read_only=ON
# relay log的文件前缀，默认值hostname-relay-bin
relay_log=relay-log
# 默认值hostname-relay-bin.index
relay_log_index=relay-log.index
```

**使用有复制权限的用户账号连接至主服务器，并启动复制线程**

```sql
-- 在从节点上执行下列SQL语句，提供主节点地址和连接账号，用户名，密码，开始同步的二进制文件和位置等

CHANGE MASTER TO MASTER_HOST='10.0.0.152',  -- 指定master节点
MASTER_USER='repluser',                     -- 连接用户
MASTER_PASSWORD='123456',                 -- 连接密码
MASTER_LOG_FILE='mysql-bin.000001',         -- 从哪个二进制文件开始复制
MASTER_LOG_POS=157,                         -- 指定同步开始的位置
MASTER_DELAY=interval                       -- 可指定延迟复制实现防误操作，单位秒，这里可以用作延时同步，一般用于备份

START SLAVE [IO_THREAD | SQL_THREAD];       -- 启动同步线程
STOP SLAVE                                  -- 停止同步
RESET SALVE ALL                             -- 清除同步信息

SHOW SLAVE STATUS;                          -- 查看从节点状态
SHOW RELAYLOG EVENTS in 'relay-bin.0000x'   -- 查看relaylog事件

-- 可以利用MASTER_DELAY参数设置从节点延迟同步，作用主从备份，比如设置1小时延时，则主节点上的误操作，要一个小时后才会同步到从服务器，可以利用时间差保存从节点数据
```

## 一主一从

主掉线，从会每隔60s进行重新连接

![image-20250108105158238](pic/image-20250108105158238.png)

### 主

创建二进制日志目录

```shell
mkdir -pv /data/mysql/logbin
chown -R mysql:mysql /data/mysql/
```

更改apparmor使其mysql能够有读取指定路径的权限（ubuntu中）

```shell
vim /etc/apparmor.d/usr.sbin.mysqld
# 加入
/data/mysql/** rw,
/data/mysql rw,

# 重新加载apparmor
apparmor_parser -r /etc/apparmor.d/usr.sbin.mysqld
```

主节点mysql配置

```ini
vim /etc/mysql/mysql.conf.d/mysqld.cnf 
[mysqld]
server-id=12
log_bin=/data/mysql/logbin/mysql-bin
# 避免出现认证问题，问题见从配置最后
default_authentication_plugin=mysql_native_password 
# bind-address记得修改
```

重启服务

```shell
systemctl restart mysql
```

同步账号授权

```shell
create user repluser@'10.0.0.%' identified by '123456';
# 指定插件
CREATE USER 'repluser'@'10.0.0.%' IDENTIFIED WITH mysql_native_password BY '123456';

grant replication slave on *.* to repluser@'10.0.0.%';

flush privileges;
```

查看二进制日志与起始位置

```sql
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |      879 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

# mysql-bin.000001 与 879
```



### 从

创建二进制日志（中继日志）目录

```shell
mkdir -pv /data/mysql/logbin
chown -R mysql:mysql /data/mysql/
```

更改apparmor使其mysql能够有读取指定路径的权限（ubuntu中）

```shell
vim /etc/apparmor.d/usr.sbin.mysqld
# 加入
/data/mysql/** rw,
/data/mysql rw,

# 重新加载apparmor
apparmor_parser -r /etc/apparmor.d/usr.sbin.mysqld
```

从节点mysql配置

```ini
vim /etc/mysql/mysql.conf.d/mysqld.cnf 
[mysqld]
server-id=204
read-only
log-bin=/data/mysql/logbin/mysql-bin
default_authentication_plugin=mysql_native_password
```

重启服务后

```shell
systemctl restart mysql.service
```

配置主从同步（mysql中）

```sql
CHANGE MASTER TO MASTER_HOST='10.0.0.12', MASTER_USER='repluser', MASTER_PASSWORD='123456', MASTER_PORT=3306, MASTER_LOG_FILE='mysql-bin.000001',MASTER_LOG_POS=849;

# 查看信息
show slave status\G
```

启动同步

```sql
START SLAVE;
```

查看线程

```sql
show processlist;
```

### 报错处理

```sql
# Error connecting to source 'repluser@10.0.0.12:3306'. This was attempt 1/86400, with a delay of 60 seconds between attempts. Message: Authentication plugin 'caching_sha2_password' reported error: Authentication requires secure connection.

-- 解决方案1：主节点改密码插件
ALTER USER 'repluser'@'10.0.0.%' IDENTIFIED WITH 'mysql_native_password' BY '123456';

-- 解决方案2：(生产中推荐，测试环境不推荐)
# 在服务器端，确保已启用 TLS/SSL。检查 MySQL 配置文件（my.cnf 或 my.ini）中的以下参数是否配置正确
[mysqld]
ssl-ca=/path/to/ca.pem
ssl-cert=/path/to/server-cert.pem
ssl-key=/path/to/server-key.pem
# 在客户端，使用 --ssl-mode=REQUIRED 强制客户端使用 TLS/SSL 连接
mysqlbinlog -R --host=10.0.0.121 --ssl-mode=REQUIRED --raw --stop-never --user=root --password=123456 ubuntu.000011
```

### 一主一从（主存在过往数据）

#### 主

配置好之前的主配置后

```sql
-- 重置二进制日志，如果从当前使用位置开始同步，则过往数据无法同步
reset master;

show master logs;
+------------------+-----------+-----------+
| Log_name         | File_size | Encrypted |
+------------------+-----------+-----------+
| mysql-bin.000001 |       157 | No        |
+------------------+-----------+-----------+
1 row in set (0.00 sec)

```

全量导出过往的数据

```shell
mysqldump -A -F --source-data=1 --single-transaction > all.sql
# 传输给从
```

#### 从

```shell
# 将all.sql文件中的下面的语句补齐
# CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000002', MASTER_LOG_POS=157;
vim all.sql
CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000002', MASTER_LOG_POS=157,MASTER_HOST='10.0.0.12',MASTER_USER='repluser', MASTER_PASSWORD='123456',MASTER_PORT=3306;

# 将数据导入
mysql < all.sql
```

## 一主多从

与一主一从实践一样，

注意有没有过往数据要导入

多从就是从多配置一遍，注意server-id要不同

![image-20250108105209351](pic/image-20250108105209351.png)

## 级联复制

![image-20250108105217904](pic/image-20250108105217904.png)

主从复制架构中，从节点从中继日志中读取到数据写入数据库后，该数据并不会写入到从节点的二进制日 志中

在级联同步架构中，有一个中间节点的角色，该节点从主节点中同步数据，并充当其它节点的数据 源，所以在此情况下，我们需要保证中间节点从主节点中同步过来的数据，同样也要写二进制日志，否则后续 节点无法获取数据。

在此架构中，中间节点要开启log_slave_updates选项，保证中间节点复制过来的数据也能写入二进制日志，为其它节点提供数据源

### 主节点

同一主一从

导出过往数据给中间节点

```shell
mysqldump -A -F --source-data=1 --single-transaction > all.sql
# 传输给中间
```

### 中间节点配置

配置中添加

```ini
vim /etc/mysql/mysql.conf.d/mysqld.cnf 
[mysqld]
server-id=204
read-only
log-bin=/data/mysql/logbin/mysql-bin
default_authentication_plugin=mysql_native_password
# 添加的
log_slave_updates 
```

导入主库数据

```shell
# 修改sql文件中的 CHANGE MASTER
vim 
CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000002', MASTER_LOG_POS=157,MASTER_HOST='10.0.0.12',MASTER_USER='repluser', MASTER_PASSWORD='123456',MASTER_PORT=3306;

mysql < all.sql
```

启动同步

```sql
# 刷新内存中权限表
flush privileges;
start slave;
```

导出中间库数据给从节点

```shell
mysqldump -A -F --source-data=1 --single-transaction > all.sql
```

### 从节点

导入中间库数据

```shell
# 修改sql文件中的 CHANGE MASTER
vim 
CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000003', MASTER_LOG_POS=157,MASTER_HOST='10.0.0.204',MASTER_USER='repluser', MASTER_PASSWORD='123456',MASTER_PORT=3306;

mysql < all.sql
```

启动同步

```sql
start slave;
```

## 主主复制

在双主模型中，两个节点互为主备，两个节点都要开启二进制日志，都要有写权限。

![image-20250108151454219](pic/image-20250108151454219.png)

Master <> Master 双主架构互为主从，要保证不同的库或表在不同的节点上，即两个节点不要同时写 一个库，双主架构一般配置为只写一个节点，这种架构的好处是可以随时将另一个节点设为主节点

### master1

配置

```ini
[mysqld]
server-id=12
log_bin=/data/mysql/logbin/mysql-bin
default_authentication_plugin=mysql_native_password
# 没有read-only，因为要写
```

同步账号授权

```shell
create user repluser@'10.0.0.%' identified by '123456';
# 指定插件
CREATE USER 'repluser'@'10.0.0.%' IDENTIFIED WITH mysql_native_password BY '123456';

grant replication slave on *.* to repluser@'10.0.0.%';

flush privileges;
```

查看二进制日志与起始位置

```sql
mysql> show master status;

# mysql-bin.000001 与 849
```

配置同步

```sql
# 特别注意：使用另一端的MASTER_LOG_FILE与MASTER_LOG_POS
CHANGE MASTER TO MASTER_HOST='10.0.0.204', MASTER_USER='repluser', MASTER_PASSWORD='123456', MASTER_PORT=3306, MASTER_LOG_FILE='mysql-bin.000002',MASTER_LOG_POS=849;
```

启动同步

```sql
start slave;
```



### master2

配置

```ini
[mysqld]
server-id=204
log_bin=/data/mysql/logbin/mysql-bin
default_authentication_plugin=mysql_native_password
# 没有read-only，因为要写
```

同步账号授权

```shell
create user repluser@'10.0.0.%' identified by '123456';
# 指定插件
CREATE USER 'repluser'@'10.0.0.%' IDENTIFIED WITH mysql_native_password BY '123456';

grant replication slave on *.* to repluser@'10.0.0.%';

flush privileges;
```

查看二进制日志与起始位置

```sql
mysql> show master status;

# mysql-bin.000002 与 849
```

配置同步

```sql
# 特别注意：使用另一端的MASTER_LOG_FILE与MASTER_LOG_POS
CHANGE MASTER TO MASTER_HOST='10.0.0.12', MASTER_USER='repluser', MASTER_PASSWORD='123456', MASTER_PORT=3306, MASTER_LOG_FILE='mysql-bin.000001',MASTER_LOG_POS=849;
```

启动同步

```sql
start slave;
```

###  双主架构的注意事项

**双主架构在实际生产环境中，并不会配置为两个节点都去写数据**

双主架构在实际生产环境中，并不会配置为两个节点都去写数据，前端应用只会写一个节点，另一个节点 作为备份节点，如果当前使用的节点出问题，则IP地址会立即转移到另一个节点上，起到一个高可用的作用， 此时，如果有slave节点，在 slave 上要重新执行同步操作。

![image-20250108164058776](pic/image-20250108164058776.png)

注意：两台数据库虽然数据是一样的，但是二进制日志有可能是不一样的

发生冲突，重新同步

```sql
stop slave;

# 跳过1个错误事件
set global sql_slave_skip_counter=1;

start slave;

set global sql_slave_skip_counter=0;

show slave status\G
```

```sql
# 除了使用 set global sql_slave_skip_counter=N 忽略错误个数之外，
# 也可以用忽略指定错误编号的方式来处理错误。
show slave status\G
# 中的Last_Errno与 Last_SQL_Errno

# 在配置中
[mysqld]
slave_skip_errors=N|ALL
```

##  半同步复制

应用程序或客户端向主节点写入数据，主节点给客户端返回写入成功或失败状态，从节点同步数据，这几个事情的步骤和执行顺序不一样，意味着不同的同步策略，从而对MySQL的性能和数据安全性有着不同的影响

*   异步复制
    *   当客户端程序向主节点中写入数据后，主节点中数据落盘， 写入binlog日志，然后将binlog日志中的新事件发送给从节点 ，便向客户端返回写入成功，而并不验证 从节点是否接收完毕，也不等待从节点返回同步状态
    *   客户端只能确认向主节点的写入是成功 的，并不能保证刚写入的数据成功同步到了从节点。
    *   异步复制不要求数据能成功同步到从节点，只要主节点完成写操作，便立即向客户端返回结果。
    *   如果主从同步出现故障，则有可能出现主从节点之间数据不一致的问题
    *   如果 在主节点写入数据后没有完成同步，主节点服务当机，则会造成数据丢失。
*   同步复制
    *   当客户端程序向主节点中写入数据后，主节点中数据落盘，写入binlog日志，然后将binlog日志中的新 事件发送给从节点 ，等待所有从节点向主节点返回同步成功之后，主节点才会向客户端返回写入成功。
    *   最大限度的保证数据安全和主从节点之间的数据一致性
    *   性能不高
*   半同步复制
    *   当客户端程序向主节点中写入数据后，主节点中数据落盘，写入binlog日志，然后将binlog日志中的新 事件发送给从节点 ，等待所有从节点中有一个从节点返回同步成功之后，主节点就向客户端返回写入成 功。
    *   至少有一个从节点中有同步到数据，也能尽早的向客户端返回写入状态。
    *   但此复制策略并不能百分百保证数据有成功的同步至从节点，可以在此策略下设至同步超时时间， 如果超过等待时间，即使没有任何一个从节点返回同步成功的状态，主节点也会向客户端返回写入成 功。
    *   如果生产业务比较关 注主从最终一致(比如:金融等)。推荐可以使用MGR的架构，或者PXC等一致性架构。

### 半同步策略

#### mysql5.7

```ini
rpl_semi_sync_master_wait_point=after_commit
```

![image-20250108191509763](pic/image-20250108191509763.png)

在此半同步策略配置中，可能会出现下列问题：

*   幻读：当客户端提交一个事务，该事务己经写入 redo log 和 binlog，但该事务还没有写入从节 点，此时处在 Waiting Slave dump 处，此时另一个用户可以读取到这条数据，而他自己却不能。
*   数据丢失：一个提交的事务在 Waiting Slave dump 处 crash后，主库将比从库多一条数据

#### mysql8.0

```ini
rpl_semi_sync_master_wait_point=after_sync
```

![image-20250108191919127](pic/image-20250108191919127.png)

在mysql8.0之后的半同步策略配置中，客户端的写操作先不提交事务，而是先写二进制日志，然后向从库同步数据，由于在主节点上的事务还没提交，所以此时其他进程查不到当前的写操作，不会出现幻读的问题，而且主节点要确认至少一个从节点的数据同步成功了，再会提交事务，这样也保证了主从之间的数据一致性，不会存在丢失的情况 

总结就是：先写二进制日志，确定从节点同步后，再提交事务落盘，从而确保主库落盘的数据是从库同步成功的。防止主从不一致

### 配置

#### 主

安装插件

```sql
INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so';

# 未启用状态
select @@rpl_semi_sync_master_enabled;

# 相关内容
show global variables like '%semi%';

show global status like '%semi%';
```

启用插件

```ini
[mysqld]
rpl_semi_sync_master_enabled
# rpl_semi_sync_master_timeout=3000                   设定同步超时时间为3秒
```

之后正常配置主从同步



#### 从

安装插件

```sql
INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';

# 未启用
select @@rpl_semi_sync_slave_enabled;
```

启用插件

```ini
[mysqld]
rpl_semi_sync_slave_enabled
```

## 复制过滤器

复制过滤器是指让从节点仅复制指定的数据库，或指定数据库的指定表。

复制过滤器的实现有两种方式：

*   在 master 节点上使用服务器选项配置来实现：在 master 节点上配置仅向二进制日志中写入与特定数据库相关的事件。
    *   优点：只需要在 master 节点上配置一次即可，不需要在 salve 节点上操作；减小了二进制日志中的数 据量，能减少磁盘IO和网络IO。
    *   缺点：二进制日志中记录的数据不完整，如果当前节点出现故障，将无法使用二进制还原。
*   在 slave 节点上使用服务器选项或者是全局变量配置来实现：在 slave 节点上配置在读取 relay log  时仅处理指定的数据库或表。





### 方案1：主节点配置

相关配置项

```ini
[mysqld]
binlog-do-db=db1              # 数据库白名单列表，不支持同时指定多个，如果想实现多个数据库需多行实现
binlog-do-db=db2

binlog-ignore-db=db3          # 数据库黑名单列表，不支持同时指定多个，如果想实现多个数据库需多行实现
binlog-ignore-db=db3
```



```ini
[mysqld]
server-id=8
rpl_semi_sync_master_enabled
log_bin=/data/mysql/logbin/mysql-bin
binlog-ignore-db=db1
binlog-ignore-db=db2
#配置白名单的方式表示仅往二进制日志中写指定的库
#配置黑名单的方式表示除了黑名单中的库或表，都写二进志日志
```

查看

```sql
# 可查看黑白名单配置情况
show master status;
```

**复制过滤规则的配置需要非常谨慎，特别是在涉及跨库或连表操作时，可能会出现同步失败的问题。**

当复制过滤规则排除了某些库或表，但事务涉及多个库时，可能会导致事务在从服务器上执行失败。例如：

-   在主服务器上执行 `INSERT INTO db1.table1 SELECT * FROM db2.table2`。
-   如果复制过滤规则只允许同步 `db1`，而 `db2` 被排除，则复制的 SQL 语句在从服务器上会因为缺少 `db2.table2` 数据而失败。

如果复制过滤规则仅允许某些表被复制，而 SQL 查询涉及多个被排除的表，则复制的 SQL 语句在从库上无法正确执行。

### 方案1：从节点配置

```ini
[mysqld]
replicate-do-db=db1        # 指定复制库的白名单，每行指定一个库，多个库写多行
replicate-do-table=tab1    # 指定复制表的白名单，每行指定一个表，多个表写多行

replicate-ignore-db=db1          # 指定复制库的黑名单，每行指定一个库，多个库写多行
replicate-ignore-table=tab1      # 指定复制表的黑名单，每行指定一个表，多个表写多行 

replicate-wild-do-table=db%.stu%      # 指定复制表的白名单，支持通配符，每行指定一个规则，多个规则写多行
replicate-wild-ignore-table=foo%.bar% # 指定复制表的黑名单，支持通配符，每行指定一个规则，多个规则写多行 
```

查看

```sql
# 可查看黑白名单配置情况
show master status;
```

## GTID复制（高并发场景）

GTID（global transaction ID）：全局事务ID

二进制日志中默认GTID是匿名

```shell
# 所有事务的操作都是都是ANONYMOUS，没有标识。这就意味着，当事务量多的时候，只能按照顺序进行处理
SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/; 
```

GTID 是一个己提交的事务的编号，由当前 MySQL 节点的 server-uuid 和每个事务的  transacton-id 联合组成，每个事务的 transacton-id 唯一，但仅只在当前节点唯一，server-uuid  是在每个节点自动随机生成，能保证每个节点唯一。基于此，用 server-uuid 和 transacton-id 联合 的 GTID 也能保证全局唯一。

开启 GTID 功能可以支持多 DUMP 线程的并发复制，而且 MySQL5.6 实现了基于库级别多 SQL 线程并 发。在 MySQL5.7 利用 GTID 的 Logic clock 逻辑时钟。保证了同库级别下的事务顺序问题。即可以实 现基于事务级别的并发回放。从而大大减少了同步的延迟。

**同时 GTID 具有幂等性特性，即多次执行结果是一样的。**

利用 GTID 复制不像传统的复制方式（异步复制、半同步复制）需要找到 binlog 文件名和 POS  点，只需知道 master 节点的 IP、端口、账号、密码即可。开启 GTID 后，执行 change master to  master_auto_postion=1 即可，它会自动寻找到相应的位置开始同步。



在传统的基于 **二进制日志位置** 的复制中，从服务器需要依赖主服务器的 binlog 文件位置来跟踪复制的进度，这可能会导致同步问题或者在复制中断时难以恢复。而使用 GTID，主从服务器不再依赖 binlog 的文件位置，而是使用事务的唯一标识符来定位事务的位置。

-   **无缝切换**：在使用 GTID 的情况下，主服务器和从服务器之间的切换更加方便，尤其是在故障转移时。从服务器能明确知道已经执行了哪些事务，因此能够准确地接收新的事务，而不需要手动记录和重置文件位置。
-   **自动追踪**：GTID 可以自动记录复制的进度，避免了手动管理日志文件位置的问题。



GTID优点

- GTID使用了master_auto_position=1替代了基于binlog和position号的主从复制方式，更便于主从复制的搭建
- GTID可以知道事务在最开始是在哪个实例上提交的，保证事务全局统一
- 截取日志更方便，跨多文件，判断起点终点更方便
- 传输日志，可以并发传送，SQL回放可以跟高并发
- 判断主从工作状态更加方便



**总结：GTID的作用：在高并发条件下，保证事务的顺序**

### 查看当前节点的server-uuid

```shell
mysql> show global variables like '%server_uuid%';
+---------------+--------------------------------------+
| Variable_name | Value                                |
+---------------+--------------------------------------+
| server_uuid   | d5cdb5a0-26df-11ef-badc-000c29bb0db4 |
+---------------+--------------------------------------+
1 row in set (0.00 sec)

# 此文件在MySQL5.7开始才有
cat /var/lib/mysql/auto.cnf
[root@ubuntu2204 ~]#cat /var/lib/mysql/auto.cnf 
[auto]
server-uuid=d5cdb5a0-26df-11ef-badc-000c29bb0db4
```

在主从架构中，主从节点可以互相获取对方节点的server-id

```sql
mysql> show slave hosts;
+-----------+------+------+-----------+--------------------------------------+
| Server_id | Host | Port | Master_id | Slave_UUID                           |
+-----------+------+------+-----------+--------------------------------------+
|       202 |      | 3306 |       200 | ca6ae13a-2586-11ef-8306-0050563b6427 |
|       201 |      | 3306 |       200 | bfde3e44-26df-11ef-acae-00505634fd39 |
+-----------+------+------+-----------+--------------------------------------+
2 rows in set, 1 warning (0.00 sec) 

# 在从slave节点上看主节点的server_id
show slave status\G
...
Master_Server_Id: 200
Master_UUID: d5cdb5a0-26df-11ef-badc-000c29bb0db4
Master_Info_File: mysql.slave_master_info.
...
```

### 配置

在master与slave都添加GTID选项

```ini
[mysqld]
gtid_mode=ON    
enforce_gtid_consistency=ON
```

之后正常配置主

**从节点配置有差别：`MASTER_AUTO_POSITION=1`**

```sql
CHANGE MASTER TO MASTER_HOST='10.0.0.12', MASTER_USER='repluser', MASTER_PASSWORD='123456', MASTER_PORT=3306, MASTER_AUTO_POSITION=1;
```

# 主从复制的监控和维护

## percona-toolkit

```
sudo apt-get install percona-toolkit
```

## 监控和维护

### 清理日志

```sql
RESET MASTER; # master环境清理binlog日志
RESET SLAVE;  # 重置mysql的主从同步
```

### 查看同步状态

```sql
SHOW MASTER STATUS;
SHOW BINARY LOGS\G
SHOW BINLOG EVENTS\G
SHOW SLAVE STATUS\G
SHOW PROCESSLIST\G
SHOW SLAVE HOSTS;         # 在主节点上查看所有的从节点列表
```

### 从服务器是否落后于主服务

```sql
show slave status\G

Seconds_Behind_Master：0  # 表示未落后
```

### 如何确定主从节点的数据是否一致

使用第三方工具percona-toolkit

```shell
 https://www.percona.com/software/database-tools/percona-toolkit
```

### 数据不一致，如何修复

重置主从关系，重新复制

**常见原因**

*   主库 binlog 格式为 Statement，同步到从库执行后可能造成主从不一致。
    *   binlog 格式：raw
*   部分操作未记入二进制日志
    *   主库执行更改前有执行set sql_log_bin=0，会使主库不记录 binlog，从库也无法变更这部分数据。
*   从节点未设置只读，误操作写入数据
*   主库或从库意外宕机，宕机可能会造成 binlog 或者 relaylog 文件出现损坏，导致主从不一致
*   主从数据库的版本不一致，特别是高版本是主，低版本为从的情况下，主数据库上面支持的功能，从数据库上面 可能不支持该功能
*   主从 sql_mode 不一致,也就是说，两方对于数据库执行的检查标准不一样
*   MySQL 自身 bug 导致



**解决方案**

*   将从库重新实现
    *   虽然这是一种解决方法，但此方案恢复时间较慢，而且有时候从库也是承担一部分的查询 操作的，不能贸然重建。
*   使用 percona-toolkit 工具辅助：PT 工具包中包含 pt-table-checksum 和 pt-table-sync 两 个工具，主要用于检测主从是否一致以及修复数据不一致情况。这种方案优点是修复速度快，不需要停止主从 辅助，缺点是需要会使用该工具，关于使用方法，可以参考下面链接： https://www.cnblogs.com/feiren/p/7777218.html
*   手动重建不一致的表：在从库发现某几张表与主库数据不一致，而这几张表数据量也比较大，手工比对数据 不现实，并且重做整个库也比较慢，这个时候可以只重做这几张表来修复主从不一致。这种方案缺点是在执行 导入期间需要暂时停止从库复制，不过也是可以接受的。





## 常见问题和解决方案

### 数据损坏或丢失

*   如果是 slave 节点的数据损坏或丢失，重置数据库，重新同步复制即可
*   如果要防止 master 节点的数据损坏或丢失，则整个主从复制架构可以用 MHA+半同步来实现，在  master 节点不可用时，提升一个 salve 节点为新的 master 节点



### 在环境中出现了不唯一的 server-id

可手动修改 server-id 至唯一，再次重新复制

```shell
/var/lib/mysql/auto.cnf 
```

### 主从复制出现延迟

*   升级到 MySQL5.7 以上版本,利用 GTID支持并发传输 binlog 及并 行多个 SQL 线程
*   减少大事务，将大事务拆分成小事务
*   减少锁
*   sync_binlog=1 (实时写入磁盘)加快 binlog 更新时间，从而加快日志复制
*   需要额外的监控工具的辅助
*   多线程复制：对多个数据库复制
*   一从多主：Mariadb10 版后支持



### 数据不一致处理

在当前主从同步中，有 A，B，C 三张表的数据在 master 节点与 slave 节点中不一致

**salve 节点停止同步**

```sql
stop slave;
```

**master 节点导出 A,B,C的备份**

```shell
mysqldump -uroot -pmagedu -q --single-transaction --master-data=2 testdb A B C >/backup/A_B_C.sql
```

**从备份文件中找到 master 节点截至到备份时的 master log 和 pos**

```shell
-- MASTERLOGFILE='mysql-bin.888888', MASTERLOGPOS=666666;   # 该条属性是注释的
```

将 A_B_C.sql 文件 scp 到 slave 节点，并在 **savle 节点上开启同步到指定位置再停下来**

作用是同步到主从还是同步的位置，为导入主库备份数据提供准备。

从库会同步到指定的位置并自动停止，此时主从数据是一致的。

```sql
mysql>start slave until MASTERLOGFILE='mysql-bin.888888',MASTERLOGPOS=666666;
```

**在 slave 节点上导入备份数据**

```sql
#在 slave 节点上导入备份数据
mysql -uroot -p123456 testdb
mysql>set sql_log_bin=0;
mysql>source /backup/A_B_C.sql
mysql>set sql_log_bin=1;
```

**恢复从库的复制**

```sql
START SLAVE;
```

明确同步起点：

-   通过记录和指定 `MASTER_LOG_FILE` 和 `MASTER_LOG_POS`，从库知道从哪里开始同步主库的后续事务。

避免事务冲突：

-   通过在指定位置停止复制再导入数据，可以确保导入的数据和主库的后续 binlog 不冲突。

保持数据一致性：

-   从库的数据会在导入后与主库保持一致，避免丢失或重复数据。



###  如何避免主从不一致

*   主库 binlog 采用 ROW 格式 
*   主从实例数据库版本保持一致 
*   主库做好账号权限把控，不可以执行 set sql_log_bin=0 
*   从库开启只读，不允许人为写入 
*   定期进行主从一致性检验



# MySQL中间件代理服务器





# MySQL高可用

