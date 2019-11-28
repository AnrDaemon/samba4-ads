[@USER@]
user = "@USER@"
group = "www-data"

listen = 127.7.1.@XADR1@:@FPORT@

;listen = "/run/php/fpm-@USER@-7.1.sock"
;listen.acl_users = "www-data,@USER@"
;!! Legacy-don't-use!
;listen.owner = $pool
;listen.group = w-@USER@
;listen.mode = 0660

access.log = "@HOME@/logs/php-access.log"
catch_workers_output = yes

pm = dynamic
pm = ondemand
pm.start_servers = 3
pm.min_spare_servers = 2
pm.max_spare_servers = 3
pm.max_children = 20

security.limit_extensions = ".php .htm .html"

php_admin_value[error_log] = "@HOME@/logs/php-error.log"
php_admin_value[user_ini.filename] = ""
;php_admin_value[user_ini.filename] = ".htphp"
php_admin_value[open_basedir] = "@HOME@:/opt/php-tools:/opt/php-lib"
php_admin_value[include_path] = ".:@HOME@/inc:/opt/php-tools:/opt/php-lib/PEAR"
php_admin_value[upload_tmp_dir] = "@HOME@/tmp"
php_admin_value[session.save_path] = "@HOME@/tmp/sessions"
php_admin_value[variables_order] = "ECGPS"
php_admin_flag[allow_url_fopen] = Off
php_admin_flag[register_argc_argv] = Off
php_admin_flag[short_open_tag] = Off
php_admin_flag[session.cookie_httponly] = On
php_admin_flag[session.use_strict_mode] = On
php_admin_flag[log_errors] = On
;php_admin_value[memory_limit] = 32M
php_admin_value[cgi.fix_pathinfo] = 2
php_value[default_mimetype]="text/html"
php_value[default_charset]="UTF-8"
php_value[request_order] = "CGP"
php_value[log_errors_max_len] = 0
php_value[output_buffering] = 4096
php_value[output_encoding] = "UTF-8"
php_value[post_max_size] = 32M
;php_value[session.cookie_lifetime] = 3600
php_value[upload_max_filesize] = 22M
php_value[realpath_cache_size] = 256K
php_flag[zlib.output_compression] = On
php_flag[track_errors] = Off
php_flag[display_errors] = Off

;php_flag[session.auto_start] = On

php_admin_value[error_reporting] = -1

;php_admin_flag[xdebug.remote_enable] = On
php_admin_flag[xdebug.remote_autostart] = Off
php_admin_flag[xdebug.remote_connect_back] = Off
php_admin_value[xdebug.remote_host] = "localhost"
php_admin_value[xdebug.remote_port] = @XPORT@
php_admin_value[xdebug.remote_handler] = dbgp
php_admin_value[xdebug.remote_mode] = req
php_admin_value[xdebug.remote_cookie_expire_time] = 30
php_admin_value[xdebug.remote_log] = "@HOME@/logs/php-xdebug.log"

php_admin_value[xdebug.idekey] = "@USER@-@UID@"
php_admin_value[xdebug.overload_var_dump] = 2
php_admin_value[xdebug.var_display_max_children] = -1
php_admin_value[xdebug.var_display_max_data] = -1
php_admin_value[xdebug.var_display_max_depth] = -1
php_admin_flag[xdebug.coverage_enable] = Off
php_admin_flag[xdebug.default_enable] = Off
php_admin_flag[xdebug.dump_globals] = Off
;php_admin_flag[xdebug.extended_info] = On
php_admin_flag[xdebug.scream] = Off
php_admin_flag[xdebug.show_error_trace] = Off
php_admin_flag[xdebug.show_exception_trace] = Off
php_admin_flag[xdebug.show_local_vars] = Off
