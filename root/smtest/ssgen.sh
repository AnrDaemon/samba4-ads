#!/bin/sh
##
## $Id: ssgen.sh 972 2018-12-10 04:04:13Z anrdaemon $
##

__help()
{
  case "$1" in
    auth|service|tests)
      "__help_$1"
      exit
      ;;
  esac

  echo "$( basename "$0" ) [-H] <command> [options]"
  echo ""
  echo "Common options:"
  echo ""
  echo "    -H|--help - print this help."
  #echo "    -D|--debug  - don't actually save anything. Trace all steps to the STDOUT."
  echo ""
  echo "Commands (use --help <command> to get help on individual commands):"
  echo ""
  echo "    auth    - create [service] auth file."
  echo "    service - Create service configuration in the ssmtp.conf(5) format."
  echo "    tests   - Generate tests."
  echo ""
  echo "Files:"
  echo ""
  echo "    ssgen.cf - Generator configuration file."
  echo "              The only required variable is _local (address of existing user)"
  echo ""
}

__help_auth()
{
  echo "$( basename "$0" ) [-H] auth [--full] [--user <username>] [<service_name>]"
  echo ""
  echo "Helps create [service] .auth file."
  echo ""
  echo "BIG WARNING: passwords with apostrophe (') are not supported by the script."
  echo "You will have to write them into the file yourself with proper quoting."
  echo ""
  echo "Options:"
  echo ""
  echo "    -F|--full - use entire email as username."
  echo "              Some server configurations require that."
  echo "    -U|--user - use this user instead of _local."
  echo "              Overrides --full."
  echo "    <service_name>"
  echo "            - create .auth.service file name instead."
  echo "              Useful if your tests require multiple different credentials."
  echo ""
}

__help_service()
{
  echo "$( basename "$0" ) [-H] service --host <mailhub> [--tls] <service_name>"
  echo ""
  echo "Create service configuration in the ssmtp.conf(5) format."
  echo ""
  echo "    -h|--host <mailhub>"
  echo "            - set address[:port] of the mailhub."
  echo "    -s|--tls"
  echo "            - use TLS to connect to the service."
  echo "              If not defined, the StartTLS is considered."
  echo ""
}

__help_tests()
{
  echo "$( basename "$0" ) [-H] tests [--services <services_config>] <tests_config>"
  echo ""
  echo "Generate individual test files from provided configuration file."
  echo "If <tests_config> is \`-' or not defined, read from STDIN."
  echo ""
  echo "Both <services_config> and <tests_config> accept colon-separated files containing"
  echo "the following fields in order:"
  echo ""
  echo "Services config file fields (see \`$( basename "$0" ) --help service'):"
  echo ""
  echo "    service - (required) name of the service;"
  echo "    host    - (required) service host;"
  echo "    port    - (optional) service port;"
  echo "    tls     - (optional flag) service should use TLS."
  echo ""
  echo "Tests config file fields (see also \`sstest.sh --help'):"
  echo ""
  echo "    service - (required) name of the service to use in this test."
  echo "            Corresponding <service>.conf file must exist in the base directory."
  echo "    test    - name of the test, will be used as a file name; if empty, the file"
  echo "            name will be constructed from concatenation of the fields' values;"
  echo "    expect  - (unimplemented) reserved for future use;"
  echo "    from    - (required) message From: address (also defines envelope-from);"
  echo "    to      - (required) envelope-to address;"
  echo "    auth    - authenticate before sending the message; if .auth.<fileld_value>"
  echo "            exists, it wil be sourced, otherwise, the .auth file will be used;"
  echo "    Message to"
  echo "            - sets message To: header, if non-empty."
  echo ""
}

__auth()
{
  _user0=
  _user="${_local%@*}"
  _target="$_dir/.auth"
  eval set -- $( getopt --options 'FU:' --longoptions 'full,user:' --shell sh --name "ssgen: auth" -- "$@" )
  for i; do
    case "$i" in
      -F|--full)
        _user="$_local"
        shift
        ;;
      -U|--user)
        _user0="$2"
        shift 2
        ;;
      --)
        shift
        break
        ;;
    esac
  done

  if [ "$1" ]; then
    _target="$_target.$1"
  fi

  _user="${_user0:-$_user}"
  read -rp "Enter auth password for user \`$_user': " _pass

  printf "%s='%s'\\n" _user "$_user" _pass "$_pass" > "$_target"
}

__service()
{
  _user=
  _host=
  _tls=UseSTARTTLS
  eval set -- $( getopt --options 'h:s' --longoptions 'host:,tls' --shell sh --name "ssgen: service" -- "$@" )
  for i; do
    case "$i" in
      -h|--host)
        _host="$2"
        shift 2
        ;;
      -s|--tls)
        _tls=UseTLS
        shift
        ;;
      --)
        shift
        break
        ;;
    esac
  done

  if [ "$1" ]; then
    [ "$_host" ] || {
      echo "Host must be defined."
      exit 2
    } >&2
    printf "mailhub=%s\\n%s=YES\\n\\nFromLineOverride=YES\\nhostname=%s\\n" "$_host" "$_tls" "$( uname -n )" > "$_dir/$1.conf"
  fi
}

__tests()
{
  _svcs=
  eval set -- $( getopt --options 'S:' --longoptions 'services:' --shell sh --name "ssgen: tests" -- "$@" )
  for i; do
    case "$i" in
      -S|--services)
        _svcs="$2"
        shift 2
        ;;
      --)
        shift
        break
        ;;
    esac
  done

  if [ "$_svcs" ]; then
    [ -f "$_svcs" ] || {
      echo "Services configuration file \`$_svcs' not found."
      exit 2
    } >&2
    while IFS=: read -r _service _host _port _tls; do
      _service="${_service##\#*}"
      [ "$_service" ] || continue

      __service --host "$_host${_port:+:$_port}" ${_tls:+--tls} "$_service"
    done < "$_svcs"
  fi

  _file=-
  if [ "$1" -a "$1" != "-" ]; then
    [ -f "$1" ] || {
      echo "Tests configuration file \`$1' not found."
      exit 2
    } >&2
    _file="$1"
  fi

  cat "$_file" | while IFS=: read -r _service _name _expect _from _to _auth _msgto; do
    _service="${_service##\#*}"
    [ "$_service" ] || continue

    [ -f "$_dir/$_service.conf" ] || {
      echo "Service \`$_service' not defined."
      exit 5
    } >&2

    if ! [ "$_name" ]; then
      _name="$(
        eval echo "$_from-$_to-${_auth:-n}-${_msgfrom:-f}-${_msgto:-t}"
      )"
    fi

    if [ "$_auth" ]; then
      if [ -f "$_dir/.auth.$_auth" ]; then
        _auth="\$_dir/.auth.$_auth"
      else
        _auth="\$_dir/.auth"
      fi
    fi

    {
      eval echo "\"_service='$_service'\""
      eval echo "\"_from='$_from'\""
      eval echo "\"_to='$_to'\""
      [ "$_msgto" ] && eval echo "\"_msgto='$_msgto'\""
      [ "$_auth" ] && echo ". \"$_auth\""
    } > "$_dir/$_service-$_name.test"
  done
}

getopt --test
if [ $? -ne 4 ]; then
  echo Enhanced 'getopt' package required. >&2
  return 4
fi

_dir="$( dirname "$( which "$0" )" )"
_debug=
_help=

eval set -- $( getopt --options '+H' --longoptions 'help' --shell sh --name ssgen -- "$@" )
for i; do
  case "$i" in
    --)
      shift
      break
      ;;
    -H|--help)
      _help=yes
      shift
      ;;
    *)
      __help
      exit 3
      ;;
  esac
done

[ "$_help" ] && {
  __help "$1"
  exit
}

. "$_dir/ssgen.cf"

[ "$_local" ] || {
  echo "Local user must be defined."
  exit 1
} >&2

_cmd="$1"
case "$_cmd" in
  auth|service|tests)
    shift
    "__$_cmd" "$@"
    return
    ;;
  *)
    __help
    exit 3
    ;;
esac
