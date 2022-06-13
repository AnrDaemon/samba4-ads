#!/bin/sh

_rcfile="${FETCHMAILHOME:-$HOME/.}${FETCHMAILHOME:+/}fetchmailrc"

(
    set -e
    cd "$( dirname "$_rcfile" )"
    cat fetchmailrc.d/*.rc fetchmailrc.d/*.poll > "$_rcfile"
)
