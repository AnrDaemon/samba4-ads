server {
    listen 80;
    server_name example.org;
    return 301 $scheme://www.example.org$request_uri;
}

server {
    server_name www.example.org;

    listen 80;

    #listen 443 ssl http2;
    #ssl_certificate "@HOME@/.ssh/@USER@.crt";
    #ssl_certificate_key "@HOME@/.ssh/@USER@.key";

    # RealIP config
    #include extra/proxy_upstream;

    # Local filter block.
    #include extra/access_local;

    # Block access to VCS dirs.
    #include extra/access_vcs;

    access_log "@HOME@/logs/access.log" combined;
    error_log "@HOME@/logs/error.log" warn;

    charset UTF-8;

    add_header "X-UA-Compatible" "IE=edge" always;

    root "@HOME@/htdocs";
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;

        #autoindex on;

        ssi on;

        #client_max_body_size 32M;

        # pass the PHP scripts to FastCGI server
        #
        location ~ [^/]\.(php)(/|$) {
            include extra/fastcgi_php_fpm;

            ssi off;

            fastcgi_param SERVER_ADMIN "webmaster@example.org";
            fastcgi_param SERVER_SIGNATURE "<address>nginx/$nginx_version server at $host port $server_port</address>";
            fastcgi_param SERVER_NAME $host;
            #fastcgi_param PHP_ADMIN_VALUE "auto_prepend_file='@HOME@/inc/sitemove.php'";

            fastcgi_pass 127.5.6.@XADR1@:@FPORT@;
            #fastcgi_pass 127.7.1.@XADR1@:@FPORT@;
        }
    }

    # Force enable SSI processing for *.ssi
    #
    #location ~ "[^/]\.ssi$" {
    #    ssi on;
    #    ssi_types *;
    #}
    include "mime.types";
    types {
        text/html ssi;
    }

    #error_page 404 /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    # deny access to .ht* files
    location ~ /\.ht {
        deny all;
    }
}
