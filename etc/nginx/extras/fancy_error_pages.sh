#!/bin/sh

_tpl='
error_page %u /-error-%u;
location = /-error-%u {
    internal;
    default_type text/html;
    return %u "<!DOCTYPE html>
<html><head>
<title>%u %s</title>
</head><body><h1>%s</h1>
<p>%s</p>
<hr/>
<address>nginx/$nginx_version server at $host port $server_port</address>
</body></html>";
}
'

echo "# Fancy error pages for nginx webserver" > "fancy_error_pages"
while IFS=: read -r _code _name _desc _ref; do
    [ "$_code" ] && printf "$_tpl" $_code $_code $_code $_code $_code "$_name" "$_name" "${_desc:-$_name}"
done >> "fancy_error_pages" < "fancy_error_pages.list"
