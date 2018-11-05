#!/bin/sh

PATH=/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin
TABLES='conntrack mangle nat filter IMQ'

eval set -- $( getopt --shell=sh --options="+rH" --longoptions="reset,help" -- "$@" )

for opt; do
  case "$opt" in
    -H|--help)
      echo "$( basename "$0" ) [--reset (-r, remove counters)] [--help (-H, this help)]"
      exit 0
      ;;
    -r|--reset)
      reset=yes
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Error parsing arguments. Try \`$( basename "$0" ) --help'." >&2
      exit 1
      ;;
  esac
done

(
  for table in $TABLES; do
    unset "_t_$table"
  done

  while read rt; do
    eval "_t_$rt=$rt"
  done

  for table in $TABLES; do
    if eval [ "\${_t_$table}" ]; then
      iptables-save -t "$table" | case "${reset:-no}" in
        'yes')
          sed -r "s/^(\:[^[:space:]]+[[:space:]]+[^[:space:]]+)[[:space:]]+\[.*$/\1/"
          ;;
        *)
          cat -
          ;;
      esac
    fi
  done
) < /proc/net/ip_tables_names
