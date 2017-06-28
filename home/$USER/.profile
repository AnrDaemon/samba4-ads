# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

export SSH_PEER_ADDR="${SSH_CLIENT%%\ *}"
export RAR='-idcdp -mdg -m4 -s'
export EDITOR=/usr/bin/nano

test -r "$HOME/.locale" && {
    while read -r L; do
        case ${L%%=*} in
            LANG*|LC_*)
                export $L
                ;;
        esac
    done < "$HOME/.locale"
}

test -r "$HOME/.environment" && {
    while read -r L; do
        case ${L%%=*} in
            PS_*)
                export $L
                ;;
        esac
    done < "$HOME/.environment"
}

screen -q -ls
if [ $? -gt 10 ] && screen -S "main" -X select . 2> /dev/null 1>&2 ; then
    read -p "$(tput setaf 2)Found a running SCREEN sesion, attach?$(tput sgr0)[Y/n] " y >&2
    if [ "${y:-y}" = "y" ]; then
      screen -aDR "main"
      logout
    fi
else
    echo "$(tput setaf 3)No running SCREEN sessions found.$(tput sgr0)" >&2
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

sudo PATH="$PATH" -Es && logout
