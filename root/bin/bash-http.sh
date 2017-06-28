#!/bin/bash
exec 33<>/dev/tcp/127.0.1.1/80
printf "%s\r\n" "GET / HTTP/1.0" "" >&33
read -d "\0" REPLY <&33
echo "$REPLY"

