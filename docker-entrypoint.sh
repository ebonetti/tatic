#!/usr/bin/env bash
set -Eeuo pipefail

trap "exit 1;" SIGINT SIGTERM

#Check environvent variables
if [ -z "$DOMAIN" ]; then
    echo "No domain specified";
    exit 1;
fi
if [ -z "$CERT" ]; then
    echo "No certificate path specified";
    exit 1;
fi

#Generate config from template
CONFIG=/etc/nginx/conf.d/default.conf

function template2conf {
    export  example_com=$DOMAIN example__com=${DOMAIN//./\\.} ssl_certificate=$CERT/fullchain.pem ssl_certificate_key=$CERT/privkey.pem;
    envsubst '$example_com,$example__com,$ssl_certificate,$ssl_certificate_key' < /etc/nginx/conf.d/templates/$1 > $CONFIG;
}

#If there are no certificates, use a dummy server to obtain them.
if [ -f "$CERT/fullchain.pem" ] && [ -f "$CERT/privkey.pem" ]; then
    template2conf static.conf
else
    template2conf dummy.conf
fi;

if [ "$1" = 'nginx' ]; then
    #Wait for certificates and nginx.
    while [ ! -f "$CERT/fullchain.pem" ] || [ ! -f "$CERT/privkey.pem" ] || [ ! -e /var/run/nginx.pid ]; do
        sleep 1;
    done;
    template2conf static.conf;
    nginx -s reload;

    #Monitor changes in certificates.
    inotifywait -qm -e modify -e close_write -e move -e move_self -e create $CERT | while read -s; do
    while read -s -t 10; do :; done;
        if [ -f "$CERT/fullchain.pem" ] && [ -f "$CERT/privkey.pem" ]; then
            nginx -s reload;
        fi;
    done;
fi &

exec "$@"