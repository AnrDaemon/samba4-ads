#!/bin/bash

fixmail(){
    [ "${1##*/}" ] || return
    [ -d "$1/.mail" ] && return
    mkdir -p "$1/.mutt"
    makeMaildir "$1/.mail" "$1/.mail"/.{OUTBOX,SENT,TRASH}
    echo 'set mbox_type=Maildir
set folder="$HOME/.mail"
set spoolfile=+/' > "$1/.mutt/muttrc"
}

makeMaildir(){
    for d; do
        mkdir -p "$d"/{cur,new,tmp}
    done
}

_u="${1:-$USER}"
getent passwd "$_u" | (
    IFS=: read -r -- _u _ _uid _gid _gecos _h _s
    fixmail "$_h"
)

if [ $( id -u ) = 0 ]; then
    fixmail "/etc/skel"
fi
