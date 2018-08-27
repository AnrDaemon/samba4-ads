#!/bin/sh

PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin

# MySQL datadir=
eval "$( mysqld --print-defaults | sed -Ee 's/[[:space:]]+--/\n/g;' | grep -E "^datadir=" )"
zonesdir="/usr/share/zoneinfo"
zonelist="$datadir/zoneinfo.list"

[ "$( readlink -e "$datadir" )" ] || exit 1
[ "$( readlink -e "$zonesdir" )" ] || exit 1

_reload=

if ! [ "$(readlink -fe "$zonelist")" ]; then
  _reload=yes
elif [ "$(wc -l < "$zonelist")" != "$( find "$zonesdir" -xdev -type f ! -iname '*.list' ! -iname '*.tab' | wc -l )" ]; then
  _reload=yes
elif ! sha256sum --check --strict --status -- "$zonelist" > /dev/null 2>&1 ; then
  _reload=yes
fi

if [ "$_reload" ]; then
  set -e
  newzones="$( mktemp "$datadir/XXXXXXXX.list" )"
  trap 'test -f "$newzones" && rm "$newzones"' EXIT HUP INT QUIT ABRT TERM
  mysql_tzinfo_to_sql "$zonesdir" 2> /dev/null | mysql --defaults-extra-file=/etc/mysql/debian.cnf -- mysql
  find "$zonesdir" -xdev -type f ! -iname '*.list' ! -iname '*.tab' -exec sha256sum -b '{}' + > "$newzones"
  mv "$newzones" "$zonelist"
fi
