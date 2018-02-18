#!/bin/sh
# $Id: macvlan.sh 153 2015-04-15 06:14:07Z anrdaemon $

set -e

print_version()
{
  echo 'IPROUTE2 MACVLAN helper script $Rev: 153 $'
}

print_examples()
{
  echo "
Example configurations:

  # Private interface (no packet forwarding inside the host)
  # Imagine your regular network interface attached to a separate cable.
  # Except it is the same cable.
  auto mac0
  iface mac0 inet static
    address 192.168.0.2
    netmask 255.255.255.0
    gateway 192.168.0.1
    dns-nameservers 192.168.0.1
    macvlan_link eth0

  # Local bridge interface (lightweight alternative to bridge-utils)
  # Similar interfaces can be used by f.e. LXC to communicate between them
  # the host, and the rest.
  auto mac1
  iface mac1 inet static
    address 192.168.1.1
    netmask 255.255.255.0
    macvlan_link eth0
    macvlan_mode bridge"
  test "$1" || echo ""
}

print_refs()
{
  echo "
SEE ALSO

  $(basename "$0") --examples, $(basename "$0") --help-full, ip(8), RFC 7042 Section 2.1"
  test "$1" || echo ""
}

print_help()
{
  echo "
Switches:

  -I,--install  install the helper from current location.
  -V,--version  print version info
  --help        print help page

Use /etc/network/interfaces to configure your macvlan interfaces.
Special parameters:

  macvlan_link <physical eth device>
        (mandatory) specifies raw device to create macvlan device on

  macvlan_mode { private | vepa | bridge | passthru }
        (optional) sets interface mode. Default is 'private'.

Use 'hwaddress ether ...' to assign persistent MAC address to the interface.
Make sure the bit 0x02 is set in your custom MAC to avoid collisions."
  test "$1" || echo ""
}

print_help_full()
{
  print_version
  print_help -n
  print_examples -n
  print_refs
}


for param; do
  case $param in
    '-I'|'--install')
      ln -fs "$(readlink -fn "$0")" /etc/network/if-pre-up.d/macvlan
      ln -fs "$(readlink -fn "$0")" /etc/network/if-post-down.d/macvlan
      ;;
    '-V'|'--version')
      print_version
      ;;
    '--examples')
      print_version
      print_examples
      ;;
    '--help-full')
      print_version
      print_help -n
      print_examples -n
      print_refs
      ;;
    *)
      print_version
      print_help -n
      print_refs
      ;;
  esac
  exit 0
done

test $IF_MACVLAN_LINK || exit 0

test $IF_HWADDRESS && HWADDR="address $IF_HWADDRESS"

case $PHASE in
  'pre-up')
    ip link set dev $IF_MACVLAN_LINK up || exit 1
    ip link add name $IFACE link $IF_MACVLAN_LINK $HWADDR type macvlan mode ${IF_MACVLAN_MODE:-private}
    ;;
  'post-down')
    ip link delete dev $IFACE type macvlan
    ;;
esac
