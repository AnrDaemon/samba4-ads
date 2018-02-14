KEYSDIR=/etc/ssh/pubkeys
test -d "$KEYSDIR" || mkdir "$KEYSDIR"

_importkeys() # $user $destdir
(
  set -e
  test "$1"
  test "$2"
  test -d "$2"
  getent passwd "$1" | while IFS=: read -r _n _ _u _g _ _h _; do
    test -f "$_h/.ssh/authorized_keys"
    test ! -L "$_h/.ssh/authorized_keys"
    test ! -e "$2/$_n"
    cp "$_h/.ssh/authorized_keys" "$2/$_n"
    chown "$_u:nogroup" "$2/$_n"
    ln -fs "$2/$_n" "$_h/.ssh/authorized_keys"
  done
)

if [ "$#" -gt 0 ]; then
  for _n in "$@"; do
    _importkeys "$_n" "$KEYSDIR"
  done
else
  getent group www-data | while IFS=: read -r _n _ _gid _; do
    getent passwd | while IFS=: read -r _n _ _u _g _ _h _; do
      if [ "$_u" -gt 999 ] && [ "$_g" = "$_gid" ]; then
        _importkeys "$_u" "$KEYSDIR"
      fi
    done
  done
fi

chmod u=rw,go= "$KEYSDIR/"*

sshd -T | grep -qiE "AuthorizedKeysFile[[:space:]]$KEYSDIR/%u" || {
  echo "Adjust your /etc/ssh/sshd_config to include"
  echo "AuthorizedKeysFile $KEYSDIR/%u %h/.ssh/authorized_keys"
}
