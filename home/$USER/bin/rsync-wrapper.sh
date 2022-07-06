#!/bin/sh
#
LANG="$(locale -uU || echo "$LANG")" export LANG
[ -f "$HOME/.ssh/agent" ] && . "$HOME/.ssh/agent"
rsync -Fxtcrv --inplace --no-motd --iconv=. --rsh="ssh" "$@" 2>> "$HOME/rsync-errors-$(date +%F).log" | tee "$HOME/rsync-$(date +%F).log" | grep -vE '/$'
