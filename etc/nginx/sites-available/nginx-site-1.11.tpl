server {
    listen       80;
    server_name  @USER@.rootdir.org @USER@.darkdragon.lan;

    # RealIP config
    include extra/proxy_upstream;

    # Local filter block.
    #include extra/access_local;

    # Block access to VCS dirs.
    include extra/access_vcs;

    access_log "@HOME@/logs/access.log" combined;
    error_log  "@HOME@/logs/error.log" warn;

    charset UTF-8;

    add_header "X-UA-Compatible" "IE=edge" always;

    root   "@HOME@/htdocs";
    index  index.php index.html;

    autoindex on;

    location / {
        try_files $uri $uri/ =404;

        #client_max_body_size 32M;

        # pass the PHP scripts to FastCGI server
        #
        location ~ [^/]\.(php|html)(/|$) {
            include        extra/fastcgi_php_fpm;

            fastcgi_param  SERVER_ADMIN     "@USER@@rootdir.org";
            fastcgi_param  SERVER_SIGNATURE "<address>nginx/$nginx_version server at $http_host port $server_port</address>";
            fastcgi_param  SERVER_NAME      $http_host;
            #fastcgi_param  PHP_ADMIN_VALUE  "auto_prepend_file='@HOME@/inc/sitemove.php'";

            fastcgi_pass   127.5.6.1:@UID@;
            #fastcgi_pass   127.7.1.1:@UID@;
        }
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # deny access to .ht* files
    location ~ /\.ht {
        deny  all;
    }
}
