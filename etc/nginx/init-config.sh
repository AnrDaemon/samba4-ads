#!/bin/sh

_dp0="$( dirname "$( readlink -e "$0" )" )"

cp --backup=existing -- "$_dp0/nginx.conf.tpl" "$_dp0/nginx.conf"

mkdir --parents "$_dp0/sites-enabled"

(
    cd "$_dp0/extras"
    ./fancy_error_pages.sh
)

ln -fsT "$_dp0/conf.d/default.conf" "$_dp0/sites-enabled/000-default.conf"

nginx -qt && systemctl restart nginx
