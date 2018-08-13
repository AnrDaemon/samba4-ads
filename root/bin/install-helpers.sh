_helpers="
lxc1:/etc/bash_completion.d/
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
      [ "$helper" -a "$dest" -a -f "/opt/scripts/$helper" ] || return
      printf "Installing %s to '%s' - " "$helper" "$dest"
      chmod +x "/opt/scripts/$helper"
      if [ -d "$dest" ]; then
        [ -L "$dest/$helper" -o ! -e "$dest/$helper" ] && ln -vfst "$dest" "/opt/scripts/$helper"
      elif [ -L "$dest" -o ! -e "$dest" ]; then
        ln -vfs "/opt/scripts/$helper" "$dest"
      else
        echo "already installed or blocked by existing file."
        return
      fi
    }
  }
done
