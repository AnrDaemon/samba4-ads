# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

export SSH_PEER_ADDR="${SSH_CLIENT%%\ *}"
export RAR='-idcdp -mdg -m4 -s'
export EDITOR="$( PATH=/usr/local/bin:/usr/bin:/bin which nano )"

test -r "$HOME/.locale" && {
    while IFS== read -r name value; do
        case "$name" in
            LANG|LC_*)
                [ "$value" ] && eval "$name=$value" export "$name"
                ;;
        esac
    done < "$HOME/.locale"
}

test -r "$HOME/.environment" && {
    while IFS== read -r name value; do
        [ "$value" ] && eval "$name=$value" export "$name"
    done < "$HOME/.environment"
}

[ -x "$HOME/bin/online.sh" ] && . "$HOME/bin/online.sh"

[ "$( which screen 2> /dev/null )" ] && {
    # Uncomment for old screen's (exit codes are lower by one)
    #_old_screen_base=9
    screen -q -ls
    if [ $? -gt ${_old_screen_base:-10} ]; then
        read -p "$(tput setaf 2)Found a running SCREEN sesion, attach?$(tput sgr0)[Y/n] " y >&2
        if [ "${y:-y}" = "y" -o "$y" = "Y" ]; then
            exec screen -aDR
        fi
    else
        echo "$(tput setaf 3)No attachable SCREEN sessions found.$(tput sgr0)" >&2
    fi
}

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "$HOME/bin" ] ; then
    export PATH="$HOME/bin:$PATH"
fi

# Prime ssh-agent if exists
[ -f "$HOME/bin/ssh-agent.sh" -a -x "$HOME/bin/ssh-agent.sh" ] && . "$HOME/bin/ssh-agent.sh" > /dev/null

# include .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
