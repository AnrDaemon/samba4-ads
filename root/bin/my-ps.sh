#!/bin/sh

{
date +%F-%H%M%S
/usr/bin/mysql --defaults-extra-file=/etc/mysql/debian.cnf -e "SHOW FULL PROCESSLIST; SHOW ENGINE INNODB STATUS;" --raw 2> /dev/null
} | tee -a $HOME/mysql-ps.txt
