CREATE DATABASE nextsj_fixture;

##create masteruser and grant privileges
grant all privileges on nextsj_fixture.* to nextsj_fixture@'%' identified by 'samjung';

#replication
grant replication slave on *.* to 'nextsj_fixture'@'%';

## flushj
flush privileges;
