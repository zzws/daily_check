# 1、 简介

Shell 用来生成 html 巡检文件。Python 3 脚本可用来执行 Shell 脚本，并将 html 文件抓取到本地。
适用于 AIX 和 Linux 平台。

# 2、部署

## 2.1、创建目录

待巡检机器上创建目录：

	mkdir -p /tmp/daily_check/log
	mkdir -p /tmp/daily_check/tmp


管理机创建目录：E:\daily_check
 这里的管理机用的是 windows，可以以换成 Linux 的。
 
## 2.2 安装必要的第三方库

	import paramiko

* paramiko 还有其他的依赖库，这里不列出 *


## 2.3 用法
**方法一：**
- 1，将 tmp 目录下的所有文件上传到待巡检机器的 `/tmp/daily_check` 目录下，
- 2，配置 `ip_list.conf` 文件，最好用 oracle 用户，否则可能脚本执行不成功。，
- 3，在管理机上执行 `daily_check.py` 。

**方法二：**
- 1，将 tmp 目录下的所有文件上传到待巡检机器的 `/tmp/daily_check` 目录下，
- 2，将`daily_check.sh` 放到 crontab 内定时执行，
- 3，配置 `ip_list.conf` 文件，用户名随意，只要有读取 `/tmp/daily_check/log` 的文件权限即可，
- 3，在管理机上执行 `daily_check.py` 。


# 3、目录结构

```
daily_check
│  get_html.py
│  ip_list.conf
│  read me.md
│
└─tmp
    └─daily_check
        │  alert_check.sh
        │  daily_check.sh
        │  daily_check.tmp
        │  db_check.sql
        │  fs_check.sh
        │
        ├─log
        │      dbcheck_it2_db.html
        │
        └─tmp


```

- 1，get_html.py 用来执行巡检脚本，并抓取 html 文件到本地
- 2，ip_list.conf 待巡检机器的配置信息。ip、端口、用户名、密码
- 3，daily_check.sh 巡检的主角本，get_html.py 调用的也是该脚本
- 4，alert_check.sh 巡检数据库在前一天的 alert 告警信息
- 5，db_check.sql 巡检数据库状态、可用性、高可用信息
- 6，fs_check.sh 巡检磁盘使用情况
- 7，log 目录用来存放 html 文件
- 8，tmp 目录用来存放巡检过程中的临时文件


# 4、巡检项目
|序号|巡检项目|
|--|--|
|1|实例状态 
|2|DG 同步状态 
|4|表空间使用率 
|5|ASM使用率 
|6|Online Log 
|7|近7天redo切换频率 
|8|SCN 健康检查Check 
|9|Last 10 RMAN backup jobs 
|10|闪回区使用率 
|11|FS使用率 
|12|alert日志 


