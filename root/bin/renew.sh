#!/bin/sh
_CP="cp --preserve=timestamps -vudR"

umask 002
sudo -u referent -- $_CP -t /home/referent/Documents -- /mnt/user/Shared/Наташа-Секретарь/. > /home/referent/cp.log 2> /home/referent/cperr.log
sudo -u user -- $_CP -t /home/.shares/d -- /mnt/user/d/. > /home/.shares/d/cp.log 2> /home/.shares/d/cperr.log
sudo -u user -- $_CP -t /home/.shares/e -- /mnt/user/e/. > /home/.shares/e/cp.log 2> /home/.shares/e/cperr.log
