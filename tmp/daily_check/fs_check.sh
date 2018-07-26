base_dir='/tmp/enmo/daily_check'

function create_table_head
{
  echo  "<table border="1" width='90%' align='center' summary='Script output'>"
}

function create_td
{
  #echo $1
  td_str=`echo $1|awk 'BEGIN{FS=" "}''{i=1;while(i<=NF) {print "<td>"$i"</td>";i++}}'`
  #echo $td_str
}


function create_tr
{
  create_td "$1"
  echo  "<tr>
    $td_str
  </tr>" >>$file_name
}

function create_table_end
{
  echo  "</table>"
}


function create_df
{

  create_table_head >>$file_name

  while read line
  do
    #echo $line
    create_tr "$line"
  done < ${base_dir}/tmp/df.tmp
  echo "<center>[<a class="noLink" href="#top">Top</a>]</center><p>" >>$file_name
  create_table_end >> $file_name
  
}


file_name=`ls /tmp/enmo/daily_check/log/dbcheck*html`
OS=`uname`
if [ $OS == "Linux" ];then
 df -h| sed 's/Mounted on/Mounted_on/' | sed '/ /!N;s/\n//;s/ \+/ /;' > ${base_dir}/tmp/df.tmp
else
 df -g | sed 's/Mounted on/Mounted_on/' |sed 's/GB blocks/GB_blocks/' > ${base_dir}/tmp/df.tmp
fi


create_df


