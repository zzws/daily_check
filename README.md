# 1�� ���

Shell �������� html Ѳ���ļ���Python 3 �ű�������ִ�� Shell �ű������� html �ļ�ץȡ�����ء�
������ AIX �� Linux ƽ̨��

# 2������

## 2.1������Ŀ¼

��Ѳ������ϴ���Ŀ¼��

	mkdir -p /tmp/daily_check/log
	mkdir -p /tmp/daily_check/tmp


���������Ŀ¼��E:\daily_check
 ����Ĺ�����õ��� windows�������Ի��� Linux �ġ�
 
## 2.2 ��װ��Ҫ�ĵ�������

	import paramiko

* paramiko ���������������⣬���ﲻ�г� *


## 2.3 �÷�
**����һ��**
- 1���� tmp Ŀ¼�µ������ļ��ϴ�����Ѳ������� `/tmp/daily_check` Ŀ¼�£�
- 2������ `ip_list.conf` �ļ�������� oracle �û���������ܽű�ִ�в��ɹ�����
- 3���ڹ������ִ�� `daily_check.py` ��

**��������**
- 1���� tmp Ŀ¼�µ������ļ��ϴ�����Ѳ������� `/tmp/daily_check` Ŀ¼�£�
- 2����`daily_check.sh` �ŵ� crontab �ڶ�ʱִ�У�
- 3������ `ip_list.conf` �ļ����û������⣬ֻҪ�ж�ȡ `/tmp/daily_check/log` ���ļ�Ȩ�޼��ɣ�
- 3���ڹ������ִ�� `daily_check.py` ��


# 3��Ŀ¼�ṹ

```
daily_check
��  get_html.py
��  ip_list.conf
��  read me.md
��
����tmp
    ����daily_check
        ��  alert_check.sh
        ��  daily_check.sh
        ��  daily_check.tmp
        ��  db_check.sql
        ��  fs_check.sh
        ��
        ����log
        ��      dbcheck_it2_db.html
        ��
        ����tmp


```

- 1��get_html.py ����ִ��Ѳ��ű�����ץȡ html �ļ�������
- 2��ip_list.conf ��Ѳ�������������Ϣ��ip���˿ڡ��û���������
- 3��daily_check.sh Ѳ������Ǳ���get_html.py ���õ�Ҳ�Ǹýű�
- 4��alert_check.sh Ѳ�����ݿ���ǰһ��� alert �澯��Ϣ
- 5��db_check.sql Ѳ�����ݿ�״̬�������ԡ��߿�����Ϣ
- 6��fs_check.sh Ѳ�����ʹ�����
- 7��log Ŀ¼������� html �ļ�
- 8��tmp Ŀ¼�������Ѳ������е���ʱ�ļ�


# 4��Ѳ����Ŀ
|���|Ѳ����Ŀ|
|--|--|
|1|ʵ��״̬ 
|2|DG ͬ��״̬ 
|4|��ռ�ʹ���� 
|5|ASMʹ���� 
|6|Online Log 
|7|��7��redo�л�Ƶ�� 
|8|SCN �������Check 
|9|Last 10 RMAN backup jobs 
|10|������ʹ���� 
|11|FSʹ���� 
|12|alert��־ 


