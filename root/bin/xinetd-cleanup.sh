#!/bin/sh
# ps ax | grep discard | grep -v grep | egrep -o "^[[:space:]]*([0-9]+)" | xargs kill -KILL
case "$1" in
  list)
    ps -C xinetd -o pid,tty,stat,time,command
    ;;
  kill)
    ( kill -0 $(cat /var/run/xinetd.pid) ) 2> /dev/null && ( ps -C xinetd -o pid --no-headers | grep -v $(cat /var/run/xinetd.pid) | xargs kill -KILL ) 2> /dev/null
    ( kill -0 $(cat /var/run/xinetd.pid) ) 2> /dev/null || ( ps -C xinetd -o pid --no-headers | xargs kill -KILL ; invoke-rc.d xinetd start ) 2> /dev/null
    ;;
  *)
    echo "xinetd trash process pool cleanup script."
    echo "Usage:"
    echo ""
    echo "  $(basename "$0") list|kill"
    ;;
esac
