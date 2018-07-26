base_dir='/tmp/enmo/daily_check'
file_name=`ls /tmp/enmo/daily_check/log/dbcheck*html`


OS=`uname`
if [ $OS == "Linux" ];then
  . ~/.bash_profile
else
  . ~/.profile
fi


function get_line
{
  
  OS=`uname`
  if [[ $OS = 'Linux' ]];then
    yesterday=`date --date='1 days ago' +'%a %b %d' `
  else
    yesterday=`TZ=aaa24 date "+%a %h %d"`
  fi

  bd

  #begin_line=`cat -n al*log | grep "$yesterday" |head -n 1|awk '{print $1}'`
  #end_line=`cat -n al*log | grep "$yesterday" |head -n 1|awk '{print $1}'`
  begin_line=`cat -n alert*log | grep "$yesterday" |head -n 1|awk '{print $1}'`
  end_line=`cat -n alert*log | grep "$yesterday" |tail -n 1|awk '{print $1}'`
  
  echo  "${begin_line} $end_line"
}


function get_ora_number
{
  
  bd

  lines=`get_line`

  begin_line=`echo $lines|awk '{print $1}'`
  end_line=`echo $lines|awk '{print $2}'`

  #echo $begin_line $end_line

  cat alert*.log |awk '{if(NR>='"$begin_line"' && NR<='"$end_line"') {print $0 " ;;"}}'|grep ORA-|sort|uniq -c >${base_dir}/tmp/alert.tmp

}

function get_ora_info
{

  bd

  lines=`get_line`

  begin_line=`echo $lines|awk '{print $1}'`
  end_line=`echo $lines|awk '{print $2}'`

  cat alert*.log |awk '{if(NR>='"$begin_line"' && NR<='"$end_line"') {print $0 " ;;"}}'|sed -e '/\*\*\*/d' | grep -vE "ORA-609|ORA-3136">${base_dir}/tmp/alert.tmp.tmp
  ora_count=`grep ORA ${base_dir}/tmp/alert.tmp.tmp|grep -v grep |wc -l`

  if [ ${ora_count} -gt 1 ];then

    OS=`uname`

    if [ $OS == "Linux" ];then
      . ~/.bash_profile
      grep -A2 -B2 -E "ORA-" ${base_dir}/tmp/alert.tmp.tmp  > ${base_dir}/tmp/alert.tmp

    else
      . ~/.profile
      before=2
      after=2
      grep -n ORA ${base_dir}/tmp/alert.tmp.tmp |cut -d':' -f1|xargs -n1 -I % awk "NR<=%+$after && NR>=%-$before"  ${base_dir}/tmp/alert.tmp.tmp | grep -E "ORA|201" >${base_dir}/tmp/alert.tmp
    fi
  else
    echo "There is no error on yesterday." >${base_dir}/tmp/alert.tmp
  fi

}


function create_table_head
{
  echo -e "<table border="1" width='90%' align='center' summary='Script output'>"
}

function create_td
{
  #echo $1
  td_str=`echo $1|awk 'BEGIN{FS=";;"}''{i=1;while(i<=NF) {print "<td align="center">"$i"</td>";i++}}'`
  #echo $td_str
}


function create_tr
{
  create_td "$1"
  echo -e "<tr> 
    $td_str
  </tr>" >>$file_name
}

function create_table_end
{
  echo -e "</table>"
}


function create_df
{

  create_table_head >>$file_name

  cp ${base_dir}/tmp/alert.tmp ${base_dir}/tmp/alert.tmp2
  while read line
  do
    #echo $line
    create_tr "$line"
  done < ${base_dir}/tmp/alert.tmp
  echo "<center>[<a class="noLink" href="#top">Top</a>]</center><p>" >> $file_name
  echo "<a name="alert_usage"><font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>12.alert日志</b></font></a>" >> $file_name
  create_table_end >> $file_name
  
}


get_ora_info
#get_ora_number
create_df
