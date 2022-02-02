echo Attempting to switch shell to bash… >&2
[ -z "$( which bash )" ] || exec "$( which bash )" -i --login
