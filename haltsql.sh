######################
# Author - Kishan M  #
######################
#!/bin/bash


#Remove the temporary files at the end of execution of script
trap 'rm -rf /home/oracle/oratab_new' EXIT
#For logging purpose
_LOG_0()
{
echo "*************************************$1"
}

#Set the environment variables
_SET_ENV_1()
{
cat /etc/oratab|grep -v '#'|grep -v '^$' > /home/oracle/oratab_new
while read x
   do
     IFS=':' read -r -a array <<< $x
                ORACLE_SID="${array[0]}"
                ORACLE_HOME="${array[1]}"
                echo $ORACLE_SID
                echo $ORACLE_HOME
                export PATH=$PATH:$ORACLE_HOME/bin
   done < /home/oracle/oratab_new
}

#Fetch the sql which takes time

_GET_SQL(){
$ORACLE_HOME/bin/sqlplus -S '/ as sysdba' <<EOF
          spool stopsql.txt
          set heading off
          set feedback off
          SELECT s.sid, s.serial# serial, sq.sql_id FROM v\$session s
                 INNER JOIN v\$sql sq on (s.sql_id = sq.sql_id)
                 WHERE sq.sql_text like '%xtbl%'
                  AND
                 sq.sql_text not like '%INNER JOIN v$sql%'
                  AND
                 sq.elapsed_time/1000000 > 1;
          spool off
exit;
EOF
}

#Stop only the specific sql without killing the session
_STOP_SQL(){
        touch sql.sql && echo -ne "EXEC stopsql('sql')\n exit;" > sql.sql
        sqlid=/home/oracle/stopsql.txt
        if [ -s $sqlid ]
        then
                sql=`cat $sqlid |awk '{print $NF}'|uniq|grep -v '^$'`
                sqlplus -S '/ as sysdba' @sql.sql
        else
                break
        fi
}



_SET_ENV_1
_GET_SQL
_STOP_SQL