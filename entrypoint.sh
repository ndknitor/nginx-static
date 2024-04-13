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
    # Add the wildcard forwarding rule to the NGINX configuration block
    sed -i '/location \/ {/a \
        try_files $uri $uri\/ \/index.html;
    ' "$nginx_conf"
fi

nginx -g 'daemon off;'