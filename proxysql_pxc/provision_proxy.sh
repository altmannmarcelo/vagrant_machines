#!/bin/bash
yum -y install http://www.percona.com/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm
yum -y install tar strace vim proxysql Percona-Server-client-57
iptables -F
setenforce 0
systemctl start proxysql
MYSQL="mysql -uadmin -padmin -h127.0.0.1 -P6032 -e "
sleep 7

$MYSQL "DELETE FROM mysql_users;"
$MYSQL "INSERT INTO mysql_users (username,password,active,default_hostgroup,default_schema,transaction_persistent) VALUES ('app','app',1,50,'information_schema',1);"
$MYSQL "LOAD MYSQL USERS TO RUNTIME; SAVE MYSQL USERS FROM RUNTIME; SAVE MYSQL USERS TO DISK;"
$MYSQL "DELETE FROM mysql_query_rules;"
$MYSQL "INSERT INTO mysql_query_rules (rule_id,username,destination_hostgroup,active,retries,match_digest,apply) VALUES(200,'app',50,1,3,'^SELECT.*FOR UPDATE',1);"
$MYSQL "INSERT INTO mysql_query_rules (rule_id,username,destination_hostgroup,active,retries,match_digest,apply) VALUES(201,'app',51,1,3,'^SELECT ',1);"
$MYSQL "LOAD MYSQL QUERY RULES TO RUNTIME; SAVE MYSQL QUERY RULES TO DISK;"
$MYSQL "DELETE FROM mysql_servers;"
$MYSQL "INSERT INTO mysql_servers (hostname,hostgroup_id,port,weight) VALUES ('$1',50,3306,100);"
$MYSQL "INSERT INTO mysql_servers (hostname,hostgroup_id,port,weight) VALUES ('$1',51,3306,1);"
$MYSQL "INSERT INTO mysql_servers (hostname,hostgroup_id,port,weight) VALUES ('$2',50,3306,10);"
$MYSQL "INSERT INTO mysql_servers (hostname,hostgroup_id,port,weight) VALUES ('$2',51,3306,100);"
$MYSQL "INSERT INTO mysql_servers (hostname,hostgroup_id,port,weight) VALUES ('$3',50,3306,1);"
$MYSQL "INSERT INTO mysql_servers (hostname,hostgroup_id,port,weight) VALUES ('$3',51,3306,100);"
$MYSQL "LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;"
