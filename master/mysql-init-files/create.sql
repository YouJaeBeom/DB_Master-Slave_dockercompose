CREATE DATABASE db_name;

##create masteruser and grant privileges
grant all privileges on db_name.* to db_name@'%' identified by 'rootpassword';

#replication
grant replication slave on *.* to 'db_name'@'%';

## flushj
flush privileges;
