#!/bin/bash
exec 8<>/dev/tcp/localhost/10011
while read -r -t 1 -u 8 REPLY; do :; done
printf "use 1\r\n" >&8
read -r -t 1 -u 8 REPLY
echo "$REPLY"
