#!/bin/bash

set -o errexit
set -o nounset

dbus_pid_file=$(/bin/mktemp)
exec 4<> ${dbus_pid_file}

dbus_add_file=$(/bin/mktemp)
exec 6<> ${dbus_add_file}

/bin/dbus-daemon --fork --print-pid 4 --print-address 6 --session

function _clean {
  kill $(cat ${dbus_pid_file})
  rm -f ${dbus_pid_file} ${dbus_add_file}
  exit 1
}
trap "{ _clean; }" EXIT

export DBUS_SESSION_BUS_ADDRESS=$(cat ${dbus_add_file})

/bin/init-checkconf "$@"
