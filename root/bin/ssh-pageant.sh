#!/bin/sh

_agent="$HOME/.ssh/agent"
test -f "$_agent" && {
  . "$_agent"
  if kill -0 "$SSH_PAGEANT_PID" 2> /dev/null; then
    if test -S $SSH_AUTH_SOCK; then
      # Agent is alive, try to restart.
      # Fail if restart fails. (I.e. if agent is running elevated for some reason.)
      /usr/bin/ssh-pageant -qk || exit 1
    else
      # Socket not readable, we aren't running as a different user, are we?
      # Assume already dead agent.
      :;
    fi
  fi
  # Reap dead agent's socket
  rm "$SSH_AUTH_SOCK" 2> /dev/null
  rm "$_agent"
}

eval set -- $( getopt --shell=sh -o 'k' -- "$@" )
test "$1" = "-k" && exit

socket="$( mktemp -u /var/run/ssh-XXXXXXXX )"
eval $( cygdrop -- /usr/bin/ssh-pageant -qsa "$socket" | tee "$_agent" )

# Remove empty settings file (agent failed to start).
test -s "$_agent" || rm "$_agent"
