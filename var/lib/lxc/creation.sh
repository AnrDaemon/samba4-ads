#!/bin/sh

test "$1" || exit 1
lxc-create --name="$1" --template=ubuntu -- --release=trusty --arch=amd64 --mirror=http://ru.archive.ubuntu.com/ubuntu \
  --packages=acl,aptitude,attr,bash-completion,curl,dnsutils,htop,iptables,man-db,mc,nano,ncurses-term,patch,screen,software-properties-common,ssl-cert,tcpdump,wget,cifs-utils,krb5-user,libnss-winbind,libpam-krb5,smbclient,samba-vfs-modules
