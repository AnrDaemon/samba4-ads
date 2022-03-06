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

_get_version()
{
  echo "AD template set v1.0"
}

_get_help()
{
  _hostname="${_hostname:-MACHINE}"
  _realm="${_realm:-ADS.EXAMPLE.LAN}"
  echo "This is a very simple domain join preparation template set.
It does not do anything, doesn't touch any system configuration, all it does
is preparing some files from initial templates.

The usage is simple:
1. Copy the directory to the target system (f.e. \`/root/samba-ads');
2. Call this script:

    samba-prep.sh { -H | -V }
    samba-prep.sh [--role=MS] [--host=<hostname>] [--realm=<KRB5_REALM>]
        [--] <DOMAINNAME>
    samba-prep.sh --role=DC [--host=<hostname>] [--realm=<KRB5_REALM>]
        [--dns=<DNS_MASTER>] [--] <DOMAINNAME>

    -H      - this help.
    -V      - tool version.
    --role  - server role - MS(Member Server) or DC(Domain Controller),
        defaults to \`MS'.
    --host  - the hostname, i.e. \`$_hostname'. Defaults to using system name.
        It is written in the config commented out. Do not uncomment it, unless
        the system does not work right.
        Which would indicate that hostname/hosts is not setup correctly and
        should be fixed in there instead.
    --realm - Kerberos version 5 realm name. Fully qualified domain name, i.e.
        \`$_realm'.
    --dns   - parent DNS server IP. Effective for domain controller only.

    <DOMAINNAME> is a domain (workgroup) short name, i.e. \`EXAMPLE'.

If only domain short name is provided, these settings will be in effect:

    role=MS, host=\$(hostname -s), realm=ADS.<domain short name>.LAN


Once $( _get_help_finished help )"
}

_get_help_finished()
{
  test "$1" || {
    printf "Now, that " ""
  }
  echo "files are generated, move them to their rightful places:

    install -bCDT -o root -g root -m 0755 nsswitch.conf /etc/nsswitch.conf
    install -bCDT -o root -g root -m 0755 krb5.conf /etc/krb5.conf
    install -bCDT -o root -g root -m 0755 smb.conf /etc/samba/smb.conf

Make sure your /etc/hosts file contains proper local resolution record:

    $( echo 127.0.1.1 ${_hostname}.${_realm} ${_hostname} | tr '[:upper:]' '[:lower:]' )

..and that your /etc/hostname contains either...

    $( echo ${_hostname}.${_realm} or just ${_hostname} | tr '[:upper:]' '[:lower:]' )

...and that local resolver is able to reach domain DNS zone.

Stop Samba daemons (nmbd, smbd, winbind).
Purge /var/lib/samba/private/ (do NOT remove directory itself).
Call \`net ads join -U <Your admin user>' or provision your domain.
Don't forget to switch over startup scripts, if you were provisioning anew.
Finally, reboot the stuff or simply start the service(s).
"
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
      _get_version
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

if [ -f /etc/nsswitch.conf ]; then
    sed -Ee '/^passwd:/{/winbind/!s/[[:space:]]*$/ winbind/;}' \
        -e '/^group:/{/winbind/!s/[[:space:]]*$/ winbind/;}' \
        -e '/^netgroup:/{/winbind/!s/[[:space:]]*$/ winbind/;}' \
        > nsswitch.conf < /etc/nsswitch.conf
else
    cp nsswitch.conf.tpl nsswitch.conf
fi

_get_help_finished
