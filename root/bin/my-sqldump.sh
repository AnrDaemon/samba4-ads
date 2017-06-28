#!/bin/sh

my_command()
{
  /usr/bin/mysql --defaults-extra-file=/etc/mysql/debian.cnf --skip-column-names --batch "$@"
}

my_dump()
{
  /usr/bin/mysqldump --defaults-extra-file=/etc/mysql/debian.cnf "$@"
}

DATABASE="${1:-$(my_command -e "SHOW DATABASES;")}"
echo "$DATABASE" | while read table; do
  case "$table" in
    information_schema|mysql|performance_schema) :;;
    *)
      test "$table" && my_dump --single-transaction --flush-logs "$table" > "/tmp/$table-$(date +%F).sql"
      ;;
  esac
done
