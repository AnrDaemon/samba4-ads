#!/bin/sh

(
  read -r _u _i _
  #_u=8; _i=7; # Online 0:00:08, 87% idle.

  _u=${_u%.*}
  idle=$(( 100 * ${_i%.*} / $_u ))

  _m=$(( $_u / 60 ))
  _s=$(( $_u - 60 * $_m ))

  _h=$(( $_m / 60 ))
  _m=$(( $_m - 60 * $_h ))

  _d=$(( $_h / 24 ))
  _h=$(( $_h - 24 * $_d ))

  [ $_d -gt 0 ] && _d="$_d days, " || _d=

  tput setaf 2
  printf "Online %s%d:%02d:%02d, %d%% idle.\\n" "$_d" $_h $_m $_s $idle
  tput sgr0
) < /proc/uptime
