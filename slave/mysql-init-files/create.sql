CREATE DATABASE dbname;

#create masteruser and grant privileges
create user dbname@'%' identified by 'password';
grant all privileges on dbname.* to dbname@'%' identified by 'password';

## flush
flush privileges;
