COLUMN filename NEW_VALUE file_name NOPRINT
--SELECT 'dbcheck_'||i.host_name||'_'||d.DB_UNIQUE_NAME||'_'||to_char(d.CONTROLFILE_TIME,'yyyymmdd_hh24') filename FROM v$database d,v$instance i;
SELECT 'dbcheck_'||i.host_name||'_'||d.DB_UNIQUE_NAME filename FROM v$database d,v$instance i;
set linesize 200
set term off
set verify off 
set feedback off 
set pagesize 5000
set markup html on entmap off spool on 
spool &file_name..html

set lines 200
set feedback off
set pages 5000

prompt <a name=top></a>
prompt <tr><td nowrap align="center" width="25%"><a class="link" href="#instance_status">1.实例状态</a></td></tr>
prompt <tr><td nowrap align="center" width="25%"><a class="link" href="#dg_status">2.DG 同步状态</a></td></tr>
prompt <tr><td nowrap align="center" width="25%"><a class="link" href="#db_tablespace">4.表空间使用率</a></td></tr>
prompt <tr><td nowrap align="center" width="25%"><a class="link" href="#db_tablespace">5.ASM使用率</a></td></tr>
prompt <tr><td nowrap align="center" width="25%"><a class="link" href="#db_onlinelog">6.Online Log</a></td></tr>
prompt <tr><td nowrap align="center" width="25%"><a class="link" href="#db_redolog">7.近7天redo切换频率</a></td></tr>
prompt <tr><td nowrap align="center" width="25%"><a class="link" href="#db_scncheck">8.SCN 健康检查Check</a></td></tr>
prompt <tr><td nowrap align="center" width="25%"><a class="link" href="#db_rman_job">9.Last 10 RMAN backup jobs</a></td></tr>
prompt <tr><td nowrap align="center" width="25%"><a class="link" href="#flash_recovery_area_usage">10.闪回区使用率</a></td></tr>
prompt <tr><td nowrap align="center" width="25%"><a class="link" href="#fs_usage">11.FS使用率</a></td></tr>
prompt <tr><td nowrap align="center" width="25%"><a class="link" href="#alert_usage">12.alert日志</a></td></tr>
prompt <tr><td nowrap align="center" width="25%"><a></a></td></tr>

--1.Instance Status
prompt <a name="instance_status"><font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>1.实例状态</b></font></a>


col db_unique_name for a15
col platform_name for a30
col current_scn for a20
col current_scn for 99999999999999999999
col flashback for a10
col last_open_incarnation_number for a10
col last_open_incarnation_number for 999

SELECT name,
       dbid,
       db_unique_name,
       TO_CHAR(created, 'yyyy-mm-dd HH24:MI:SS') creation_date,
       platform_name,
       current_scn,
       log_mode,
       open_mode,
       force_logging,
       flashback_on flashback,
       controlfile_type,
       last_open_incarnation# last_open_incarnation_number
  FROM v$database;
  
col host_name for a20
SELECT   instance_number,
         instance_name,
         host_name,
         version,
         TO_CHAR (startup_time, 'yyyy-mm-dd hh24:mi:ss') startup_time,
         status
  FROM   gv$instance;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


--2.DG Status
prompt <a name="dg_status"><font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>2.DG 同步状态</b></font></a>
set define off
select thread#,applied,max(sequence#) from v$archived_log  group by thread# ,applied order by 1,2;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



--4.db_tablespace
prompt <a name="db_tablespace"><font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>4.表空间使用率</b></font></a>
set define off

-- ........
col status for a10
col name for a20
col TYPE for a15
col extent_mgt for a10
col segment_mgt for a10
col Ts_Size(MB) for a15
col Ts_Size(MB) for 9999999999
col Free(MB) for a15
col Free(MB) for 9999999999
col Used(MB) for a15
col Used(MB) for 9999999999
col pct_used for a8
col pct_used for 9999999999
SELECT DECODE(d.status, 'OFFLINE', 'Offline', d.status) status,
       d.tablespace_name name,
       d.contents TYPE,
       d.extent_management extent_mgt,
       d.segment_space_management segment_mgt,
       ROUND(a.bytes / 1048576) "Ts_Size(MB)",
       ROUND(f.bytes / 1048576) "Free(MB)",
       ROUND((a.bytes - NVL(f.bytes, 0)) / 1048576) "Used(MB)",
       ROUND((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 2) pct_used
  FROM sys.dba_tablespaces d,
       (SELECT tablespace_name, SUM(bytes) bytes
          FROM dba_data_files
         GROUP BY tablespace_name) a,
       (SELECT tablespace_name, SUM(bytes) bytes
          FROM dba_free_space
         GROUP BY tablespace_name) f
 WHERE d.tablespace_name = a.tablespace_name(+)
   AND d.tablespace_name = f.tablespace_name(+)
   and d.contents <> 'TEMPORARY'
 ORDER BY 9 desc;
 

set define off
prompt <font size="+0" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>&nbsp;&nbsp;5 ASM 使用率</b></font>
set define on

col name for a20
 select name,
       total_mb,
       free_mb,
       round((total_mb - free_mb) / total_mb * 100, 2) as "USED_PER"
  from v$asm_diskgroup;
  

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


--6.online log....
prompt <a name="db_onlinelog"><font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>6.Online Log</b></font></a>

--online log Status
SELECT   group#,
         thread#,
         bytes / 1024 / 1024 "Size(MB)",
         members,
         archived,
         status,
         TO_CHAR (first_time, 'yyyy-mm-dd hh24:mi:ss') first_time
  FROM   v$log;
  
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

--7.Relog Switch
prompt <a name="db_redolog"><font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>7.近7天redo切换频率</b></font></a>
col total for a6
col total for 999999
col Avg for a6
col Avg for 999999
column        day        format a20                heading 'Day'
column        d_0        format a3                heading '00'
column        d_1        format a3                heading '01'
column        d_2        format a3                heading '02'
column        d_3        format a3                heading '03'
column        d_4        format a3                heading '04'
column        d_5        format a3                heading '05'
column        d_6        format a3                heading '06'
column        d_7        format a3                heading '07'
column        d_8        format a3                heading '08'
column        d_9        format a3                heading '09'
column        d_10       format a3                heading '10'
column        d_11        format a3                heading '11'
column        d_12        format a3                heading '12'
column        d_13        format a3                heading '13'
column        d_14        format a3                heading '14'
column        d_15        format a3                heading '15'
column        d_16        format a3                heading '16'
column        d_17        format a3                heading '17'
column        d_18        format a3                heading '18'
column        d_19        format a3                heading '19'
column        d_20        format a3                heading '20'
column        d_21        format a3                heading '21'
column        d_22        format a3                heading '22'
column        d_23        format a3                heading '23'
select   
        substr(to_char(FIRST_TIME,'YYYY/MM/DD DY'),1,15) day,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0))) d_0,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0))) d_1,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0))) d_2,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0))) d_3,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0))) d_4,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0))) d_5,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0))) d_6,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0))) d_7,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0))) d_8,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0))) d_9,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0))) d_10,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0))) d_11,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0))) d_12,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0))) d_13,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0))) d_14,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0))) d_15,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0))) d_16,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0))) d_17,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0))) d_18,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0))) d_19,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0))) d_20,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0))) d_21,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0))) d_22,
        decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0))) d_23,
        count(1) "Total",
        round(count(1)/24,2) "Avg"
from
        v$log_history where first_time> sysdate-7
group by
        substr(to_char(FIRST_TIME,'YYYY/MM/DD DY'),1,15)
order by
        substr(to_char(FIRST_TIME,'YYYY/MM/DD DY'),1,15);

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

--11.SCN Health..(11.2.0.2..SCN........16K.11.2.0.2....32K)
prompt <a name="db_scncheck"><font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>8.SCN 健康检查</b></font></a>
col scn for a20
col scn for 99999999999999999999999
SELECT to_char(tim, 'yyyy-mm-dd hh24:mi:ss') curr_time,
       scn,
       round((chk16kscn - scn) / 24 / 3600 / 16 / 1024, 1) "Headroom(Days)"
  FROM (select tim,
               scn,
               ((((to_number(to_char(tim, 'YYYY')) - 1988) * 12 * 31 * 24 * 60 * 60) +
               ((to_number(to_char(tim, 'MM')) - 1) * 31 * 24 * 60 * 60) +
               (((to_number(to_char(tim, 'DD')) - 1)) * 24 * 60 * 60) +
               (to_number(to_char(tim, 'HH24')) * 60 * 60) +
               (to_number(to_char(tim, 'MI')) * 60) +
               (to_number(to_char(tim, 'SS')))) * (16 * 1024)) chk16kscn
          from (select sysdate tim,dbms_flashback.get_system_change_number scn
                from dual))
 ORDER BY tim;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

---9.Last 10 Rman backup job
prompt <a name="db_rman_job"><font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>9.Last 10 RMAN backup jobs</b></font></a>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN backup_name           FORMAT a130   HEADING 'Backup Name'          ENTMAP off
COLUMN start_time             HEADING 'Start Time'           ENTMAP off
COLUMN elapsed_time           HEADING 'Elapsed Time'         ENTMAP off
COLUMN status                              HEADING 'Status'               ENTMAP off
COLUMN input_type                          HEADING 'Input Type'           ENTMAP off
COLUMN output_device_type                  HEADING 'Output Devices'       ENTMAP off
COLUMN input_size                          HEADING 'Input Size'           ENTMAP off
COLUMN output_size                         HEADING 'Output Size'          ENTMAP off
COLUMN output_rate_per_sec                 HEADING 'Output Rate Per Sec'  ENTMAP off

SELECT
    '<div nowrap><b><font color="#336699">' || r.command_id                                   || '</font></b></div>'  backup_name
  , '<div nowrap align="right">'            || TO_CHAR(r.start_time, 'yyyy-mm-dd HH24:MI:SS') || '</div>'             start_time
  , '<div nowrap align="right">'            || TO_CHAR(r.end_time, 'yyyy-mm-dd HH24:MI:SS') || '</div>'            end_time 
  , '<div nowrap align="right">'            || r.time_taken_display                           || '</div>'             elapsed_time
  , DECODE(   r.status
            , 'COMPLETED'
            , '<div align="center"><b><font color="darkgreen">' || r.status || '</font></b></div>'
            , 'RUNNING'
            , '<div align="center"><b><font color="#000099">'   || r.status || '</font></b></div>'
            , 'FAILED'
            , '<div align="center"><b><font color="#990000">'   || r.status || '</font></b></div>'
            , '<div align="center"><b><font color="#663300">'   || r.status || '</font></b></div>'
    )                                                                                       status
  , r.input_type                                                                            input_type
  , r.output_device_type                                                                    output_device_type
  , '<div nowrap align="right">' || r.input_bytes_display           || '</div>'  input_size
  , '<div nowrap align="right">' || r.output_bytes_display          || '</div>'  output_size
  , '<div nowrap align="right">' || r.output_bytes_per_sec_display  || '</div>'  output_rate_per_sec
FROM
    (select /*+ RULE */
         command_id
       , start_time
       , end_time
       , time_taken_display
       , status
       , input_type
       , output_device_type
       , input_bytes_display
       , output_bytes_display
       , output_bytes_per_sec_display
     from v$rman_backup_job_details
     where start_time > sysdate - 10
     order by start_time 
    ) r;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

----10.闪回区使用率
prompt <a name="flash_recovery_area_usage"><font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>10.Flash Recovery Area Usage</b></font></a>

select * from v$flash_recovery_area_usage;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- 11 fs usage
prompt <a name="fs_usage"><font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>11.文件系统使用率</b></font></a>

spool off
quit
