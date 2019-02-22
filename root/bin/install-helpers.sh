#!/bin/sh

_helpers="
histpurge.php:/usr/local/bin/histpurge
iptables-save-ordered.sh:/usr/local/sbin/iptables-save-ordered
macvlan.sh:/etc/network/if-pre-up.d/macvlan
macvlan.sh:/etc/network/if-post-down.d/macvlan
ngdissite:/usr/local/sbin/
ngensite:/usr/local/sbin/
nginx-helpers:/etc/bash_completion.d/
"

for helper in $_helpers
do
  [ "$helper" ] && {
    echo "$helper" | {
      IFS=: read -r helper dest
      if [ "$helper" -a "$dest" -a -f "/opt/scripts/$helper" ]; then
        printf "Installing %s: " "$helper"
        chmod +x "/opt/scripts/$helper"
        if [ -d "$dest" ]; then
          [ -L "$dest/$helper" -o ! -e "$dest/$helper" ] && ln -vfst "$dest" "/opt/scripts/$helper"
        elif [ -L "$dest" -o ! -e "$dest" ]; then
          ln -vfs "/opt/scripts/$helper" "$dest"
        else
          echo "already installed or blocked by existing file."
        fi
      fi
    }
  }
done
