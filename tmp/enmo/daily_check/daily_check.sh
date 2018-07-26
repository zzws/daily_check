export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
OS=`uname`
if [ $OS == "Linux" ];then
  . ~/.bash_profile
else
  . ~/.profile
fi

cd /tmp/enmo/daily_check/log
$ORACLE_HOME/bin/sqlplus / as sysdba <<EOF
@/tmp/enmo/daily_check/db_check.sql
EOF

sh /tmp/enmo/daily_check/fs_check.sh
sh /tmp/enmo/daily_check/alert_check.sh
