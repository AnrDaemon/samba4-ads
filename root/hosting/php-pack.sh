test -r ./packages-php.list || exit 2
_vers=$(( ${1%%.*} + 0 )).$(( ${1#*.} + 0 ))
shift
apt-get install "$@" $( sed -e "s/@v@/$_vers/;" ./packages-php.list )
