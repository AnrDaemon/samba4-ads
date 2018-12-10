#!/bin/sh
##
## $Id: sstest.sh 966 2018-12-08 22:30:48Z anrdaemon $
##

__help()
{
  echo "$( basename "$0" ) [--auth] [--from <address>] [--to <address>] [--service <service>] [--] [<testcase>]"
  echo ""
  echo "Common options:"
  echo ""
  echo "    -H|--help   - print this help."
  echo "    -D|--debug  - don't actually run the test. Print summary."
  echo ""
  echo "Case settings:"
  echo ""
  echo "    --auth      - read from <dir>/.auth file for _user= and _pass= variables."
  echo "            If defined, these variables will be used to authenticate to the"
  echo "            gateway."
  echo "    --from <address>"
  echo "                - override MAIL FROM address from the testcase."
  echo "    --to <address>"
  echo "                - override RCPT TO address from the testcase."
  echo "    --service <service>"
  echo "                - use named service description file."
  echo ""
  echo "Case file variables:"
  echo ""
  echo "_dir=   - (automatic) test suite's base directory;"
  echo "_from=  - MAIL FROM address;"
  echo "_to=    - RCPT TO address;"
  echo "_msgto= - (optional) recipient address in the message header;"
  echo "_service="
  echo "        - a service (configuration file base name) to use."
  echo ""
  echo ".auth file variables:"
  echo ""
  echo "_user=  - (required) authentication user;"
  echo "_pass=  - (optional) authentication password."
  echo ""
  echo "Authentication variables can also be used in test cases, but it is recommended"
  echo "to source \`\$_dir/.auth' instead to have a consistent experience."
}

getopt --test
if [ $? -ne 4 ]; then
  echo Enhanced 'getopt' package required. >&2
  return 4
fi

_dir="$( dirname "$( which "$0" )" )"
_debug=
_user=
_pass=

eval set -- $( getopt --options 'HD' --longoptions 'auth,debug,from:,help,to:,service:' --name sstest --shell sh -- "$@" )
for i; do
  case "$i" in
    --auth)
      . "$_dir/.auth"
      shift
      ;;
    -D|--debug)
      _debug="yes"
      shift
      ;;
    --from)
      _from0="$2"
      shift 2
      ;;
    --to)
      _to0="$2"
      shift 2
      ;;
    --service)
      _service0="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -H|--help)
      __help
      exit
      ;;
    *)
      __help
      exit 3
      ;;
  esac
done

[ "$1" ] && {
  . "$_dir/$( basename "$1" .test ).test"
}

# Sort the variables' source preference.
_service="${_service0:-$_service}"
_from="${_from0:-$_from}"
_to="${_to0:-$_to}"

# See if service definition is available
_ss="$_dir/${_service}.conf"
[ -f "$_ss" ] || {
  echo "No configuration file \`$_ss' found."
  exit 1
} >&2

if [ "$_debug" ]; then
  echo "$_service: $_from => $_to"
  [ "$_user" ] && echo "auth: ${_user:+-au "$_user"} ${_pass:+-ap "$_pass"}"
else
  printf "From: %s\\nTo: %s\\nSubject: Test: %s\\n\\nTest.\\n" "$_from" "${_msgto:-$_to}" "$( date "+%F %H:%M:%S" )" | /usr/sbin/ssmtp -vC "$_ss" ${_user:+-au "$_user"} ${_pass:+-ap "$_pass"} -- "$_to"
fi
