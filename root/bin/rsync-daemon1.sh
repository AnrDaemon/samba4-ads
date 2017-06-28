#!/bin/sh
#
export LANG=$(locale -uU)
test -r "$HOME/.ssh_agent" && . "$HOME/.ssh_agent"
/bin/rsync -Fxtcrv --iconv=. --rsh="ssh" --rsync-path='$HOME/bin/rsyncd' -- "$HOME/Documents/" "anrdaemon@Daemon1::Documents/" > "$HOME/rsync-Documents-$(date +%F).log" 2>> "$HOME/rsync-errors-$(date +%F).log"
