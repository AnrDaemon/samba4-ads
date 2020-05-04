#!/bin/sh

[ -x /usr/bin/ssh-agent ] || return
[ -d "/run/user/$( id -u )" ] || return

_agent="$HOME/.ssh/agent"
eval set -- $( getopt --shell=sh -o 'k' -- "$@" )

test -f "$_agent" && . "$_agent"

if [ "$SSH_AGENT_PID" ]; then
  test "$1" = "-k" && /usr/bin/ssh-agent -k > /dev/null 2>&1

  if ! kill -0 "$SSH_AGENT_PID" 2> /dev/null; then
    # Reap dead agent's socket
    rm "$SSH_AUTH_SOCK" "$_agent" 2> /dev/null
    unset SSH_AUTH_SOCK SSH_AGENT_PID
  fi
fi

test "$1" = "-k" && exit
test "$SSH_AGENT_PID" && return

socket="$( mktemp -u "/run/user/$( id -u )/ssh-XXXXXXXX" )"
eval $( /usr/bin/ssh-agent -sa "$socket" | tee "$_agent" )

# Remove empty settings file (agent failed to start).
test -s "$_agent" || rm "$_agent"
