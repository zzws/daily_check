# --coding:utf8--

import paramiko
import sys, traceback, os, time
import threading

# 远端执行目录
remote_path = '/tmp/daily_check/log'

# 本地存放html目录
loc_path = 'E:\daily_check'

# 多线程分片配置，假如有1000个机器，那么并发就是1000/parallel_num = 500个并发
parallel_num = 5

now_time = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time()))

testm = time.time()


def clac_time(func):
    # function_name 用来判断执行的是哪一步，显示不通的耗时信息
    function_name = str(func).split()[1]

    def f_clac_time(*args, **kwargs):
        begin_time = time.time()
        ret = func(*args, **kwargs)
        if function_name == 'exec_sh':
            print("execute time consume：%ss" % (format(time.time() - begin_time, '0.2f')))
        elif function_name == 'scp_get':
            print("scp time consume：%ss" % (format(time.time() - begin_time, '0.2f')))
        else:
            print ("time consume:%ss" % (format(time.time() - begin_time, '0.2f')))
        return ret

    return f_clac_time


def make_dir():
    """每天一个文件夹"""
    dir_name = time.strftime("%Y-%m-%d", time.localtime())
    today_path = loc_path + '\\' + dir_name

    if not os.path.exists(loc_path):
        os.makedirs(loc_path)
    else:
        pass

    if not os.path.exists(today_path):
        print("create dir %s" % today_path)
        os.makedirs(today_path)
        return (today_path)
    else:
        return (today_path)

def exec_sh(ip, port, username, password):
    '''执行每日巡检脚本'''
    conn = paramiko.SSHClient()
    conn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    conn.connect(hostname=ip, port=port, username=username, password=password)
    try:
        # print("begin execute daily check at %s" % ip)
        stdin, stdout, stderr = conn.exec_command("cd /tmp/daily_check/;sh daily_check.sh")
        # print(stdout.read())
        # print(stderr.read())
    except:
        print(str(traceback.format_exc()))
    conn.close()

def scp_get(ip, port, username, password, remote_path, loc_path):
    """抓取 exec_sh 生成的html """
    scp = paramiko.Transport((ip, port))
    scp.connect(username=username, password=password)
    sftp = paramiko.SFTPClient.from_transport(scp)
    files = sftp.listdir(remote_path)
    # print("begin get file from %s" % ip)
    for file in files:
        sftp.get(os.path.join(remote_path + '/' + file), os.path.join(today_path, file))
    scp.close()


@clac_time
def daily_check(line):

    for host_info in line:

        ip = host_info.split()[0]
        port = int(host_info.split()[1])
        username = host_info.split()[2]
        password = host_info.split()[3]
        try:
            # print (host_info)
            print ("begin daily check at %s ."%ip)
            #exec_sh(ip, port, username, password)
            scp_get(ip, port, username, password, remote_path, loc_path)
            print("  end daily check at %s ." % ip)
        except:
            print(str(traceback.format_exc()))
            print("%s failed" % ip)


if __name__ == "__main__":

    # 创建当天文件夹
    today_path = make_dir()

    f = open(r'ip_list.conf')
    lines = f.readlines()

    # 并行执行检查
    for i in range(0, len(lines), int(parallel_num)):
        b = lines[i:i + parallel_num]
        t = threading.Thread(target=daily_check, args=(b,))
        t.start()
        t.join()
    f.close()
print(time.time() - testm)
