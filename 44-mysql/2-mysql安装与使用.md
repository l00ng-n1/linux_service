# MySQL 安装

## MySQL 的三个主要分支

*   MySQL
    *   [MySQL :: MySQL Community Downloads](https://dev.mysql.com/downloads/)

*   Mariadb
    *   MariaDB是MySQL的一个分支，由MySQL的创始人Michael Widenius主导开发，主要由开源社区在维 护,MariaDB的发展速度非常快，在大多数情况下与MySQL兼容。
    *   [Download MariaDB Server - MariaDB.org](https://mariadb.org/download/?t=repo-config)
*   Percona Server
    *   Percona Server是MySQL数据库服务器的一个改进版，完全与MySQL兼容，专注于数据库服务器本身的优 化。

## 包管理器安装

CentOS9 系列光盘镜像自带 mysql-server 8.0 和 mariadb-server 10.3

### yum

```shell
yum install -y mysql-server
apt install mysql-server

# 安装mariadb会删除mysql
yum install -y mariadb-server
apt install mariadb-server
```



## 二进制预编译包安装

传统的二进制包安装需要进行三步：configure --- make  --- make install  而mysql的二进制包是指己经编译完成【也就是说，make已经做过了】，以压缩包提供下载的文件，下载到本 地之后释放到自定义目录，再进行配置即可。

[MySQL :: Download MySQL Community Server](https://dev.mysql.com/downloads/mysql/)

```shell
wget https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-8.4.3-linux-glibc2.28-x86_64.tar.xz
tar -xf mysql-8.4.3-linux-glibc2.28-x86_64.tar.xz
mv mysql-8.4.3-linux-glibc2.28-x86_64 /mysql
```

安装依赖

```shell
yum -y install libaio numactl-libs ncurses-compat-libs

apt install libaio-dev numactl libnuma-dev libncurses-dev
# ubuntu24系统没有libaio1的包，需要单独去下载安装
curl -O http://launchpadlibrarian.net/646633572/libaio1_0.3.113-4_amd64.deb
dpkg -i libaio1_0.3.113-4_amd64.deb
```

配置

```shell
groupadd -r mysql
useradd -r -g mysql -s /sbin/nologin mysql


# 加入环境变量
echo 'PATH=//mysql/bin:$PATH' > /etc/profile.d/mysql.sh
source /etc/profile.d/mysql.sh

# 创建相关目录
mkdir -p /mysql/{data,log,binlog,relaylog,run,tmp}
vim /mysql/my.cnf
[mysql]
socket=/data/mysql/run/mysql.sock

[mysqld]
port=3306
mysqlx_port=33060

basedir=/mysql
lc_messages_dir=/mysql/share

datadir=/mysql/data
tmpdir=/mysql/tmp
log-error=/mysql/log/alert.log
slow_query_log_file=/mysql/log/slow.log
general_log_file=/mysql/log/general.log
socket=/mysql/run/mysql.sock
pid-file=/mysql/run/mysqld.pid


innodb_data_file_path=ibdata1:128M:autoextend
innodb_buffer_pool_size=2G

# 软链接到etc下
ln -sv /mysql/my.cnf /etc/my.cnf

# Default options are read from the following files in the given order:
# /etc/my.cnf /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf ~/.my.cnf
```

初始化,本地root用户 - 使用密码

如果使用 --initialize 选项会生成随机密码，要去 /data/mysql/mysql.log中查看 

如果使用 --initialize-insecure -选项会生成空密码

```shell
mysqld --defaults-file=/mysql/my.cnf --initialize
mysqld --defaults-file=/mysql/my.cnf --initialize-insecure

chown -R mysql:mysql /mysql

# 查看密码
vim /mysql/log/alert.log
```

启动脚本

/mysql/support-files/mysql.server不是systemd风格的脚本，但是可以被 systemd兼容

```shell
cp /mysql/support-files/mysql.server /etc/init.d/mysqld
# 修改对应
vim/etc/init.d/mysqld
basedir=/mysql
datadir=/mysql/data

systemctl daemon-reload
/etc/init.d/mysqld start
systemctl cat mysqld.service
```

自写启动脚本

```shell
vim /lib/systemd/system/mysql.service
[Unit]
Description=MySQL Community Server
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
Type=notify
User=mysql
Group=mysql
PIDFile=/mysql/data/run/mysqld.pid
PermissionsStartOnly=true
#ExecStartPre=/usr/share/mysql/mysql-systemd-start pre
ExecStart=/mysql/bin/mysqld --defaults-file=/mysql/my.cnf
TimeoutSec=infinity
Restart=on-failure
RuntimeDirectoryMode=755
LimitNOFILE=10000

# Set enviroment variable MYSQLD_PARENT_PID. This is required for restart.
Environment=MYSQLD_PARENT_PID=1

systemctl daemon-reload
systemctl start mysql.service
```

启动

```shell
mysql -uroot -p'123456' -h127.0.0.1 -P3306

mysql -uroot -p'123456' -S run/mysql.sock

# 进入后更改密码
alter user 'root'@'localhost' identified by 'PASSWORD'
```

## 多示例mysql

在 MySQL 中，多个示例（即多实例）配置通常是指在同一台服务器上运行多个 MySQL 实例，每个实例都使用不同的配置、端口、数据目录和 socket 文件。



**双实例`3307`与`3308`**

目录，文件创建

```shell
mkdir /3307
mkdir /3308
mkdir -p /3307/{data,log,binlog,relaylog,run,tmp}
mkdir -p /3308/{data,log,binlog,relaylog,run,tmp}

vim /3307/my.cnf
vim /3308/my.cnf

[mysqld]
port=3307
mysqlx_port=33070

basedir=/3307
lc_messages_dir=/mysql/share

datadir=/3307/data
tmpdir=/3307/tmp
log-error=/3307/log/alert.log
slow_query_log_file=/3307/log/slow.log
general_log_file=/3307/log/general.log
socket=/3307/run/mysql.sock
pid-file=/3307/run/mysqld.pid

innodb_data_file_path=ibdata1:128M:autoextend
innodb_buffer_pool_size=2G
```

初始化

```shell
mysqld --defaults-file=/3307/my.cnf --initialize-insecure
mysqld --defaults-file=/3308/my.cnf --initialize-insecure

chown -R mysql:mysql /3307
chown -R mysql:mysql /3308
```

定制启动脚本

```shell
vim /lib/systemd/system/mysql-3307.service
vim /lib/systemd/system/mysql-3308.service

[Unit]
Description=MySQL Community Server
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
Type=notify
User=mysql
Group=mysql
PIDFile=/3307/data/run/mysqld.pid
PermissionsStartOnly=true
#ExecStartPre=/usr/share/mysql/mysql-systemd-start pre
ExecStart=/mysql/bin/mysqld --defaults-file=/3307/my.cnf
TimeoutSec=infinity
Restart=on-failure
RuntimeDirectoryMode=755
LimitNOFILE=10000

# Set enviroment variable MYSQLD_PARENT_PID. This is required for restart.
Environment=MYSQLD_PARENT_PID=1

systemctl daemon-reload
systemctl start mysql3307.service
systemctl start mysql3308.service

ss -tnulp
tcp          LISTEN         0              151                                *:3307                             *:*            users:(("mysqld",pid=11562,fd=20))                             
tcp          LISTEN         0              151                                *:3308                             *:*            users:(("mysqld",pid=11336,fd=22))                             
tcp          LISTEN         0              70                                 *:33080                            *:*            users:(("mysqld",pid=11336,fd=19))                             
tcp          LISTEN         0              70                                 *:33070                            *:*            users:(("mysqld",pid=11562,fd=19)) 
```

连接mysql

```shell
mysql -S /3307/run/mysql.sock
mysql -S /3308/run/mysql.sock
```



## 源码编译安装

下载指定版本源码在本地进行编译安装



# MySQL

*   **服务端主要组成**

    *   mysqld_safe
        *   安全启动脚本

    *   mysqld
        *   服务端程序，是mysql服务的核心程序

    *   mysqld_multi
        *   多实例工具

*   **客户端主要组成**

    *   mysql
        *   基于mysql 协议的交互式 CLI 工具

    *   mysqldump
        *   备份工具

    *   mysqladmin
        *   服务端管理工具

    *   mysqlimport
        *   数据导入工具

*   **MyISAM存储引擎的管理工具**
    *   myisamchk
        *   检查MyISAM库
    *   myisampack
        *   打包MyISAM表，只读



**配置文件**

*   /etc/mysql/*
*   /etc/my.cnf
*   /etc/my.cnf.d/*

## MySQL命令行

```shell
mysql [OPTIONS] [database]

# 版本获取
mysql -V

# 指定用户名，主机，端口
mysql -uroot -pPASSWD -h127.0.0.1 -P3306 

# 以html格式显示信息
mysql -H

# 以xml格式显示信息
mysql -X

# 非交互执行mysql命令
mysql -e "show databases;"

# 以定制的 行 格式输出
mysql -e "show databases;" -E
*************************** 1. row ***************************
Database: information_schema
*************************** 2. row ***************************
Database: mysql
*************************** 3. row ***************************
Database: performance_schema
*************************** 4. row ***************************
```

## mysql交互界面命令

```shell
mysql>

# 帮助
?

# 清屏
system clear

# 调用系统命令
system hostname

#退出客户端
quit
exit

# 显示当前状态
status

# 执行SQL脚本文件
source xxx.sql
. xxx.sql

# 重新连接
connect

# 自定义SQL语句分隔符
mysql> delimiter $$
mysql> CREATE PROCEDURE example() BEGIN SELECT 1; END$$
mysql> delimiter ;

# 设置编码
mysql> SET NAMES utf8;

# 先编辑SQL语句，再执行
edit

# 内容重定向
tee db-rs.txt
select version();
notee # 结束重定向
```

## mysqladmin

```shell
# 客户端版本
mysqladmin -V
# 服务端版本
mysqladmin version
# 状态
mysqladmin status

# 测试主机服务存活性
mysqladmin --connect-timeout=2 ping
mysqladmin -h localhost --connect-timeout=2 ping
mysqladmin -h 127.0.0.1 --connect-timeout=2 ping

# 在MySQL连接中，127.0.0.1和localhost虽然都代表本机地址，但它们的连接方式和网络协议有所不同。
# localhost使用Unix域套接字进行连接，不受网络防火墙和网卡限制；
# 而127.0.0.1则通过TCP/IP协议进行连接，可能受到网络防火墙的限制。
# 在权限设置和认证方面，这两个地址也是分开处理的。

# 持续ping
mysqladmin -i 1 ping
mysqladmin -i 1 -c 3 ping

# mysqladmin 只能关闭服务，不能启动服务
```

数据库操作

```shell
# 创建数据库
mysqladmin create db1

# 删除数据库
mysqladmin drop db1
```

