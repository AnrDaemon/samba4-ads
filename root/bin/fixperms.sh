#!/bin/sh

test -d .ssh || exit 2
test -f .ssh/authorized_keys || touch .ssh/authorized_keys

USER="${PWD#/home/}"

getent passwd "$USER" > /dev/null || exit 2

chown -R "$USER":www-data .
chown -R "$USER":nogroup ./.ssh
chown -R "$USER":adm ./logs

setfacl -RPk \
 -m u::rwX,u:$USER:rwX,u:anrdaemon:rwX,g::rX,g:www-data:rX,m::rwx,o::- \
 -m d:u::rwX,d:u:$USER:rwX,d:u:anrdaemon:rwX,d:g::rX,d:g:www-data:rX,d:m::rwx,d:o::- \
 .

setfacl -b . ./.ssh ./.ssh/authorized_keys
setfacl -m o::rX,d:u::rwX,d:u:$USER:rwX,d:u:anrdaemon:rwX,d:g::rX,d:g:www-data:rX,d:m::rwx,d:o::- . ./.ssh

ls -ld . .??* .ssh/authorized_keys
