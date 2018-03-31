      xat(){
        if [ "$2" = "-u" ]; then
          _host="$1"
          shift 2
          if [ "$1" ]; then
            set -- "$_host" "$@"
          else
            set -- "$_host" "$USER"
          fi
        fi
        eval $(inscreen -t "LXC:$*") `sudo lxc-attach -n "${1:-dc1}" -- su -l "${@:2}"`
      }; readonly -f xat
      xvb(){ xsu virtualbox;}; readonly -f xvb
