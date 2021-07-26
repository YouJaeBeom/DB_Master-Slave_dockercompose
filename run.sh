#!/bin/bash
docker-compose -f ./docker-compose.yml up -d

sleep 5

master_log_file=`mysql -h127.0.0.1 --port 33306 -uroot -ppassword -e "show master status\G" | grep mysql-bin`
master_log_file=${master_log_file}



master_log_file=${master_log_file//[[:blank:]]/}

master_log_file=${${master_log_file}#File:}

echo ${master_log_file}

master_log_pos=`mysql -h127.0.0.1 --port 33306  -uroot -ppassword -e "show master status\G" | grep Position`
master_log_pos=${master_log_pos}


master_log_pos=${master_log_pos//[[:blank:]]/}

master_log_pos=${${master_log_pos}#Position:}

echo ${master_log_pos}


query="CHANGE MASTER TO MASTER_HOST='db_master', MASTER_USER='dbname', MASTER_PASSWORD='rootpassword', MASTER_LOG_FILE='${master_log_file}', MASTER_LOG_POS=${master_log_pos} ,master_port=33306"


mysql -h127.0.0.1 --port 43306 -uroot -psamjung -e "stop slave"
mysql -h127.0.0.1 --port 43306 -uroot -psamjung -e "${query}"
mysql -h127.0.0.1 --port 43306 -uroot -psamjung -e "start slave"
