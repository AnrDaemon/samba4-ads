      acl(){ /usr/bin/getfacl "${1-.}" "${@:2}";}; readonly -f acl
      inscreen(){
        screen -q -ls
        if [ $? -gt 10 ] && screen -S "main" -X select . 2> /dev/null 1>&2 ; then
          printf 'screen -S "main" -X screen'
          printf ' "%s"' "$@"
          printf ' --'
        fi
      }; readonly -f inscreen
alias lld='ls -ld'
      xat(){
        eval $(inscreen -t "LXC:$*") sudo lxc-attach -n \"\${1:-dc1}\" -- sudo -i \"\${@:2}\"
      }; readonly -f xat
alias xsc='screen -aDR "main"'
      xsu(){
        if [ "$1" ]; then
          eval $(inscreen -t "\\\$ |shell($1):") sudo -u "\$1" -i
        else
          eval $(inscreen -t "# |sudo($USER):") sudo PATH="\$PATH" -Es
        fi
      }; readonly -f xsu
      xvb(){ xsu virtualbox;}; readonly -f xvb
      __set_prompt()
      {
        test "$PS_ORIG" || PS_ORIG="$PS1"
        test "$PC_ORIG" || eval "PC_ORIG='$PROMPT_COMMAND'"
        PROMPT_COMMAND=__bash_prompt
      }; readonly -f __set_prompt
      __bash_prompt()
      {
        local ERRORLEVEL=$?
        if [ $ERRORLEVEL != 0 ]; then
          ERRORLEVEL="\n[$(tput setaf 1)$ERRORLEVEL$(tput sgr0)]"
        else
          ERRORLEVEL=
        fi

        eval "$PC_ORIG"
        [ "$PS_ORIG" ] && PS1="$ERRORLEVEL$PS_ORIG"
      }; readonly -f __bash_prompt
