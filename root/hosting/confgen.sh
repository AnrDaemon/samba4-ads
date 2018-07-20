#!/bin/sh

set -e

test "$USER"
getent passwd "$USER" | (
  set -e

  IFS=: read -r USER _ UID GID _ HOME _

  test -d "$HOME"

  FPORT=$(( 1 + $UID % 64511 ))
  XPORT=$(( 1024 + $UID % 64511 ))
  XADR1=$(( 1 + ( $UID / 64511 ) % 254 ))

  for f in *.tpl; do
    _f="$(basename "$f" .tpl)"
    sed -e "s*@USER@*$USER*g;
      s*@HOME@*$HOME*g;
      s*@UID@*$UID*g;
      s*@FPORT@*$FPORT*g;
      s*@XADR1@*$XADR1*g;
      s*@XPORT@*$XPORT*g;" > "$_f.conf" < "$f"
    if [ "$1" = "-i" ]; then
      case "$_f" in
        apache*|nginx*|php*)
          _t="${_f#*-}"
          if [ "$_t" = "$_f" ]; then
            continue
          fi
          if [ "$_t" ]; then
            mv -b -- "$_f.conf" "$_t.conf"
          fi
          ;;
      esac
    fi
  done
)
