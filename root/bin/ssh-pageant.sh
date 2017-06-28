#!/bin/sh

test -r "$HOME/.ssh_agent" && {
  . "$HOME/.ssh_agent"
  if kill -0 "$SSH_PAGEANT_PID" 2> /dev/null; then
    if test -r $SSH_AUTH_SOCK; then
      # Agent is alive, try to restart.
      # Fail if restart fails. (I.e. if agent is running elevated for some reason.)
      ssh-pageant.exe -qk || exit 1
    else
      # Socket not readable, we aren't running as a different user, are we?
      # Assume already dead agent.
      :;
    fi
  fi
  # Reap dead agent's socket
  rm "$SSH_AUTH_SOCK" 2> /dev/null
  rm "$HOME/.ssh_agent"
}

eval set -- $(getopt -o 'k' -- "$@")
test "$1" = "-k" && exit

socket="$(mktemp -u /var/run/ssh-XXXXXXXX)"
eval $(ssh-pageant.exe -qsa "$socket" | tee "$HOME/.ssh_agent")

# Remove empty settings file (agent failed to start).
test -s "$HOME/.ssh_agent" || rm "$HOME/.ssh_agent"
