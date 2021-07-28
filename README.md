# Docker을 통한 데이터베이스 master - slave 관계 생성하기



## 🔍 Replication 란 


복제는 마스터 데이터베이스 또는 서버로 알려진 다양한 데이터베이스에서 여러 슬레이브 서버로 데이터를 복사하는 프로세스입니다. 마스터 서버는 복제용 데이터를 제공하기 때문에 그렇게 알려져 있습니다. 복제된 데이터는 완전한 데이터베이스 세트, 단일 데이터베이스 또는 원하는 데이터베이스에서 가져온 데이터 테이블일 수 있습니다.



마스터-슬레이브 구성에서 슬레이브 중 하나에 대한 모든 변경 사항은 몇 초 만에 마스터 레코드에 자동으로 반영되고, 그 후 모든 슬레이브는 마스터 서버에서 완전 자동화된 방식으로 데이터 업데이트를 수신합니다. 



## 복제의 몇 가지 주요 기능:

- Scalability: 하나 이상의 슬레이브 서버를 사용하면 데이터 읽기를 수행할 수 있으므로 쓰기 작업만 수행할 수 있는 마스터 서버의 부하가 줄어듭니다.
- Backup Assistance: 여기에는 백업 데이터로 사용할 수 있는 슬레이브로 데이터를 복제하는 작업이 포함됩니다. 그러면 이 백업이 안정적인 상태의 독립 실행형 서버로 작동할 수 있습니다.
- Data Analysis: 복제가 있는 상태에서 마스터 서버에 추가 부하를 추가하지 않고 슬레이브 서버에서 데이터를 분석 할 수 있습니다.
- Distribution of Data: 복제를 사용하면 마스터 서버에 연결하지 않고도 이 데이터에 대해 로컬로 작업할 수 있습니다. 후속 연결 시 업데이트된 데이터가 마스터와 병합됩니다


MariaDB를 사용하면 전체 데이터베이스를 전체적으로 복제하거나 데이터베이스에서 특정 양의 데이터를 선택할 수 있습니다. MariaDB의 복제는 마스터-슬레이브 구성으로 사용되며 모든 데이터 업데이트가 수행되는 마스터 서버에서 binlog를 활성화합니다. 마스터 서버는 모든 트랜잭션에 대해 글로벌 트랜잭션 ID(GTID)를 사용하고 이를 바이너리 로그에 씁니다.





GTID(글로벌 트랜잭션 ID)를 사용하면 서로 복제하는 서로 다른 서버에서 동일한 binlog 이벤트를 쉽게 고유하게 식별할 수 있습니다. 이진 로그에는 데이터베이스에 대한 모든 변경 사항(데이터 및 구조 모두)과 각 명령문이 실행되는 데 걸린 시간이 포함됩니다. 슬레이브는 복제할 데이터에 접근하기 위해 각 마스터로부터 바이너리 로그(binlog)를 읽어온다. 슬레이브 서버에서는 바이너리 로그와 동일한 형식으로 릴레이 로그를 생성하여 복제를 수행합니다.





## MariaDB의 복제 유형



MariaDB를 사용하면 사용자가 다양한 방법을 사용하여 데이터를 복제할 수 있습니다.
- Master-slave replication.
- Master-master replication.
- Multi-source replication.
- Star replication.


## 🐳 Master-Slave Replication (docker) start

MariaDB를 docker로 Master-Slave 구조로 설정하는 방법을 알아보도록 하겠습니다.

![image](https://user-images.githubusercontent.com/49609287/126984259-32437f5b-5cbe-4536-ae77-c299a3248ac9.png)

일단 디렉토리의 구성은 이런식입니다. 각자 용도는 아래와 같습니다.

- docker-compose.yml : mariadb image를 통해서 Master - Slave DB container를 생성합니다.
- mariadb_root_password.txt : DB container의 root 비밀번호를 저장하는 파일입니다.
- master : Master DB container 관련된 데이터가 저장된 파일입니다.
  - master/config/my.cnf :  Master DB container를 만들때의 설정 파일입니다.
  - master/mysql-init-files/create.sql : Master DB container를 만들때의 DB 생성 및 권한 설정 등 역할을 하는 파일입니다.
- slave : Slave DB container 관련된 데이터가 저장된 파일입니다.
  - slave/config/my.cnf :  Slave DB container를 만들때의 설정 파일입니다.
  - slave/mysql-init-files/create.sql : Slave DB container를 만들때의 DB 생성 및 권한 설정 등 역할을 하는 파일입니다.
- run.sh : 전체적으로 docker container를 띄우고 각 DB생성 몇 권한 설정등을 한번에 하는 파일입니다.


## 🚴단계별로 이제 하나씩 알아보겠습니다.

### 🔫 1. docker-compose.yml 
```
version: "3.3"

services:
  db_master:
    image: mariadb:10.6.3-focal
    container_name: db_master
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD_FILE: /run/secrets/mariadb_root_password
    volumes:
      - ./master/data:/var/lib/mysql
      - ./master/config/:/etc/mysql/conf.d
      - ./master/mysql-init-files/:/docker-entrypoint-initdb.d/
    ports:
      - "33306:3306"
    secrets:
      - mariadb_root_password

  db_slave:
    image: mariadb:10.6.3-focal
    container_name: db_slave
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD_FILE: /run/secrets/mariadb_root_password
    volumes:
      - ./slave/data:/var/lib/mysql
      - ./slave/config/:/etc/mysql/conf.d
      - ./slave/mysql-init-files/:/docker-entrypoint-initdb.d/
    ports:
      - "43306:3306"
    secrets:
      - mariadb_root_password
    depends_on:
      - db_master

secrets:
  mariadb_root_password:
    file: ./mariadb_root_password.txt
```
services 내에 두개가 존재하는것을 확인 할 수 있습니다. 

db_master 가 Master DB 역할을 하는 것이며, db_slave가 Slave DB 역할을 합니다.

각 옵션별로 살펴보면 

- image 는 mariadb:10.6.3-focal 라는 image name은 mariadb, tag 는 10.6.3-focal 사용했습니다. 
- container_name : 말그대로 docker container를 띄울때의 이름이 됩니다.
- restart : 이 옵션은 다시 작동할 수 있도록 해줍니다.
- environment/MYSQL_ROOT_PASSWORD_FILE : container 생성 후 root의 비밀번호를 저장한 파일을 설정함으로서 root 비밀번호를 설정합니다.
- volumes/./master/data:/var/lib/mysql : 각종 log와 index등이 volume이 저장되는 디렉토리 설정입니다.
-  volumes/./master/config/:/etc/mysql/conf.d : 이전에 나왔던 ./master/config/my.cnf 를 써줌으써 설정을 reference해줍니다.
-  ./master/mysql-init-files/:/docker-entrypoint-initdb.d/ : 이 파일은 이전에 /master/mysql-init-files/create.sql 을 referecnes 해줌으로서 초기에 DB를 생성하고 권한을 설정하도록 해줍니다.
-  ports :  이 옵션은 docker engine에게 각 container에게 포트를 수동으로 설정하게 해줍니다. master 는 33306으로 했고, slave 는 43306 으로 설정햇습니다.
-  depends_on : 이 옵션은 slave 에게만 쓰여져 있는데 이건 slave가 master container를 참조한다는 내용입니다.

### 🔫 2. master container 설정

기본 디렉토리에서 master 로 이동합니다.

![image](https://user-images.githubusercontent.com/49609287/126986454-e7d80c3e-ff02-4c7c-af25-a6a8d6380aed.png)

그 후 총 2가지의 파일들을 알아보겠습니다.

#### 🗡 master/config/my.cnf 

```
[mysqld]
log-bin=mysql-bin
server-id=1
```

위와 같이 Master DB container는 설정해줍니다.

#### 🗡 master/mysql-init-files/create.sql

```
CREATE DATABASE dbname; 

##create masteruser and grant privileges
grant all privileges on dbname.* to dbname@'%' identified by 'rootpassword';

#replication
grant replication slave on *.* to 'dbname'@'%';

## flushj
flush privileges;
```
첫번째로는 복제할 데이터베이스를 생성하고, 해당 DB에 권한을 설정합니다.

그 다음 slave에게 replication할 권한을 주고, 저장합니다.

여기서 사용자들은 dbname 이나 password 등만 수정하면 됩니다. 


### 🔫 3. Slave container 설정

기본 디렉토리에서 slave 로 이동합니다.

![image](https://user-images.githubusercontent.com/49609287/126987487-55747d6d-649e-4b26-b33e-978924814a85.png)

그 후 총 2가지의 파일들을 알아보겠습니다.

#### 🗡 slave/config/my.cnf 

```
[mysqld]
log-bin=mysql-bin
server-id=2
relay-log=relaylog
log-slave_updates=1
```

위와 같이 Slave DB container는 설정해줍니다.


#### 🗡 master/mysql-init-files/create.sql

```
CREATE DATABASE dbname;

#create masteruser and grant privileges
create user dbname@'%' identified by 'rootpassword';
grant all privileges on dbname.* to dbname@'%' identified by 'rootpassword';

## flush
flush privileges;
```

여기서 DB를 만드는 이유는 첫 replication하기 위해서 싱크를 맞추기 위함입니다. 

한마디로 master에서 설정한 dbname 과 password를 똑같이 써줍니다.


### 🔫 4. run.sh 실행하기

```
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


mysql -h127.0.0.1 --port 43306 -uroot -prootpassword -e "stop slave"
mysql -h127.0.0.1 --port 43306 -uroot -prootpassword -e "${query}"
mysql -h127.0.0.1 --port 43306 -uroot -prootpassword -e "start slave"
```

이제 모든 과정을 실행시키는 파일입니다. 

```
docker-compose -f ./docker-compose.yml up -d
```
는 master slave db container를 띄웁니다.


```
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
```
는 master db container의 replication 할 db의  log_file 과 log_pos 값을 정규식을 통해서 가져옵니다. 


```
query="CHANGE MASTER TO MASTER_HOST='db_master', MASTER_USER='dbname', MASTER_PASSWORD='rootpassword', MASTER_LOG_FILE='${master_log_file}', MASTER_LOG_POS=${master_log_pos} ,master_port=33306"


mysql -h127.0.0.1 --port 43306 -uroot -prootpassword -e "stop slave"
mysql -h127.0.0.1 --port 43306 -uroot -prootpassword -e "${query}"
mysql -h127.0.0.1 --port 43306 -uroot -prootpassword -e "start slave"
```

그 다음 slave db container의 db를 master db container 내의 db 에게 slave 구조를 가지도록 합니다.

또한 이제 start slave를 통해서 master - slave 구조를 시작합니다.


# 🏹  마무리 
 

실행 명령어는 아래와 같습니다.

 
```
source run.sh
 ```

실행 후 이제 결과를 확인해봐야합니다.

 

Slave DB container에 접속하여 DB에 들어가도록 합니다.

 
```
## option 1
docker exec -it db_slave /bin/bash

mysql -u root -p
>> rootpassword

## option 2 
mysql mysql -h127.0.0.1 --port 43306 -uroot -prootpassword
```

 

데이터베이스에 들어온 후 아래와 같은 명령어를 사용합니다.

 
```
show slave status\G
 ```

사용하게 되면 아래와 같은 화면이 나오게 됩니다. 

 
![image](https://user-images.githubusercontent.com/49609287/127104010-85a7928e-5013-42fe-a8d1-8e45602225ef.png)


 

여기서 우리는 Last_Errno 는 0, Last_IO_Errno가 0이면 설정이 완료된것 입니다.

 

 

설정을 완료하게 되면 이제 Master container에서 복제설정한 DB에 데이터가 들어가거나 삭제되는경우 Slave DB에도 바로 적용되는 것을 확인 할 수 있습니다.



