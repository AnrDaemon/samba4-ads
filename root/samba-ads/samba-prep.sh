#!/bin/sh

test "$( getopt --test )" && {
  echo "Requires 'enhanced' getopt."
  exit 4
} >&2

test -r "./smb.conf.tpl" -a ! -d "./smb.conf.tpl" || {
  echo "Run this script in a directory containing 'smb.conf.tpl' template file."
  exit 3
} >&2

test -r "./krb5.conf.tpl" -a ! -d "./krb5.conf.tpl" || {
  echo "Run this script in a directory containing 'krb5.conf.tpl' template file."
  exit 3
} >&2

_get_help()
{
  echo "Help."
}

_clean_value() # $allowedChars $string
{
  printf "%s" "$2" | tr -Cd "$1"
}

eval set -- $( getopt -n "$( basename -- "$0" )" -o 'VH' -l 'host:' -l 'role:' -l 'realm:' -l 'dns:' --shell sh -- "$@" )

for opt; do
  case "$opt" in
    "-H")
      _get_help
      exit 0
      ;;
    "-V")
      echo "Version."
      exit 0
      ;;
    "--role")
      _role="$2"
      shift 2
      ;;
    "--realm")
      _realm="$( _clean_value "[:alnum:]-." "$2" )"
      shift 2
      ;;
    "--host")
      _hostname="$( _clean_value "[:alnum:]-" "$2" | tr '[:lower:]' '[:upper:]' )"
      shift 2
      ;;
    "--dns")
      _DNS_master="$( _clean_value "[0-9]." "$2" )"
      shift 2
      ;;
    "--")
      shift
      break
      ;;
  esac
done
_domain="$( _clean_value "[:alnum:]-" "$1" | tr '[:lower:]' '[:upper:]' )"

test "${_domain:?Requires domain name!}${_realm:=ADS.${_domain}.LAN}${_hostname:=$( hostname -s | tr '[:lower:]' '[:upper:]' )}"
test "$_DNS_master" && {
  test ${#_DNS_master} -ge 7 || {
    echo DNS master must be an IP address.
    exit 3
  }
} >&2

if [ "$_role" != "DC" ]; then
  _role=MS
else
  _role=DC
fi

< "./smb.conf.tpl" sed -e "
    s*^\#$_role**;
    s*@WORKGROUP@*$_domain*g;
    s*@REALM@*$( printf "%s" "$_realm" | tr '[:lower:]' '[:upper:]' )*g;
    s*@FQDN@*$( printf "%s" "$_realm" | tr '[:upper:]' '[:lower:]' )*g;
    /@HOSTNAME@/{
      s*^\;$_role**;
      s*@HOSTNAME@*$_hostname*g;
    }
" | if [ "$_DNS_master" ]; then
  sed -e "
    /@DNS_MASTER@/{
      s*^\;$_role**;
      s*@DNS_MASTER@*$_DNS_master*g;
    }
"
else
  cat -
fi > "./smb.conf"

< "./krb5.conf.tpl" sed -e "
    s*@REALM@*$( printf "%s" "$_realm" | tr '[:lower:]' '[:upper:]' )*g;
" > "./krb5.conf"
