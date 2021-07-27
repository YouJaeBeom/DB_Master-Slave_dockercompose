CREATE DATABASE db_name;

#create masteruser and grant privileges
create user db_name@'%' identified by 'rootpassword';

grant all privileges on db_name.* to db_name@'%' identified by 'rootpassword';

## flush
flush privileges;
