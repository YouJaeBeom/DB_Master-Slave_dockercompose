CREATE DATABASE nextsj_fixture;

#create masteruser and grant privileges
create user nextsj_fixture@'%' identified by 'samjung';

grant all privileges on nextsj_fixture.* to nextsj_fixture@'%' identified by 'samjung';

## flush
flush privileges;
