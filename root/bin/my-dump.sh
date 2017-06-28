#!/bin/sh
/usr/bin/mysqldump --defaults-extra-file=/etc/mysql/debian.cnf "$@"
