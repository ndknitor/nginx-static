#!/bin/bash
ssl_folder="/ssl"
crt_file="app.crt"
key_file="app.key"

nginx_conf="/etc/nginx/nginx.conf"
default_worker_connections=1024
worker_connections=${WORKER_CONNECTIONS:-$default_worker_connections}
sed -i "s/\(worker_connections\s*\)[0-9]*;/\1$worker_connections;/" "$nginx_conf"

if [ ! -e "$ssl_folder/$crt_file" ] || [ ! -e "$ssl_folder/$key_file" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$ssl_folder/$key_file" -out "$ssl_folder/$crt_file" -subj "/C=VN/ST=State/L=City/O=Organization/CN=kn.kn"
fi

if [ "$INDEX_WILDCARD_FORWARDING" = "1" ]; then
        echo "
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
    worker_connections  $worker_connections;
}
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile        on;
    keepalive_timeout  65;
    server {
        listen       80;
        listen  [::]:80;
        server_name  localhost;
        #access_log  /var/log/nginx/host.access.log  main;
        location / {
            root   /app;
            try_files \$uri \$uri/ /index.html;
            index  index.html index.htm;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /app;
        }
    }


    server {
        listen       443 ssl;
        listen  [::]:443 ssl;
        server_name  localhost;
        ssl_certificate /ssl/app.crt;
        ssl_certificate_key /ssl/app.key;
        #access_log  /var/log/nginx/host.access.log  main;
        location / {
            root   /app;
            try_files \$uri \$uri/ /index.html;
            index  index.html index.htm;
        }
        #error_page  404              /404.html;
        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /app;
        }
    }

}" > "$nginx_conf"
fi
nginx -g 'daemon off;'