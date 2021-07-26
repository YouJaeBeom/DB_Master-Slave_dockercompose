CREATE DATABASE dbname;

##create masteruser and grant privileges
grant all privileges on dbname.* to dbname@'%' identified by 'password';

#replication
grant replication slave on *.* to 'dbname'@'%';

## flushj
flush privileges;
