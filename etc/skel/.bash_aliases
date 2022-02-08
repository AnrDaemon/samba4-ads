      acl(){ /usr/bin/getfacl "${1-.}" "${@:2}";}; readonly -f acl
alias e='${VISUAL:-${EDITOR:-${SELECTED_EDITOR:?"Define VISUAL or EDITOR environment variable!"}}} '
      inscreen(){
        if screen -S "main" -Q select . 2> /dev/null 1>&2 ; then
          printf 'screen -S "main" -X screen '
          printf "'%s' " "$@" "--"
        fi
      }; readonly -f inscreen
alias lld='ls -ld '
alias man='xsc man '
      xsc(){
        _sh="$( inscreen )"
        if [ "$_sh" ]; then
          eval $( inscreen -t "\\\$ |shell(${1:--}):" ) "$@"
        elif [ "$1" ]; then
          echo No running screen session found. >&2
          eval "$@"
        else
          screen -aDR "main"
        fi
      }; readonly -f xsc
      xsh(){ eval $(inscreen -t "SSH:$*") 'ssh "$@"';}; readonly -f xsh
      xsu(){
        if ! [ "$1" ]; then
          set -- "root" -iH
        fi
        eval $(inscreen -t "\\\$ |sudo($USER:$1):") 'sudo -u "$@"'
      }; readonly -f xsu
      __set_prompt()
      {
        test "$PS_ORIG" || PS_ORIG="$PS1"
        test "$PC_ORIG" || eval "PC_ORIG='$PROMPT_COMMAND'"
        PROMPT_COMMAND=__bash_prompt
      }; readonly -f __set_prompt
      eval "__bash_prompt()
      {
        local ERRORLEVEL=\$?
        if [ \$ERRORLEVEL != 0 ]; then
          ERRORLEVEL=\"\\n[$(tput setaf 1)\$ERRORLEVEL$(tput sgr0)]\"
        else
          ERRORLEVEL=
        fi

        eval \"\$PC_ORIG\"
        [ \"\$PS_ORIG\" ] && PS1=\"\$ERRORLEVEL\$PS_ORIG\"
      }"; readonly -f __bash_prompt
