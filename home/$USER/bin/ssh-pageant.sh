#!/bin/sh

[ -x /usr/bin/ssh-pageant ] || return
[ -d "/run/user/$( id -u )" ] || return

_agent="$HOME/.ssh/agent"
eval set -- $( getopt --shell=sh -o 'k' -- "$@" )

test -f "$_agent" && . "$_agent"

if [ "$SSH_PAGEANT_PID" ]; then
  test "$1" = "-k" && /usr/bin/ssh-pageant -qk 2> /dev/null

  if ! kill -0 "$SSH_PAGEANT_PID" 2> /dev/null; then
    # Reap dead agent's socket
    rm "$SSH_AUTH_SOCK" "$_agent" 2> /dev/null
    unset SSH_AUTH_SOCK SSH_PAGEANT_PID
  fi
fi

test "$1" = "-k" && exit
test "$SSH_PAGEANT_PID" && ssh-add -l > /dev/null 2>&1 && exit

# Attempting to restart the agent
socket="$( mktemp -u "/run/user/$( id -u )/ssh-XXXXXXXX" )"
eval $( cygdrop -- /usr/bin/ssh-pageant -qsa "$socket" | tee "$_agent" )

# Remove empty settings file (agent failed to start).
test -s "$_agent" || rm "$_agent"

test -f "$SSH_AUTH_SOCK" -a -L "$HOME/.ssh/auth_sock" && ln -fsT "$SSH_AUTH_SOCK" "$HOME/.ssh/auth_sock"
