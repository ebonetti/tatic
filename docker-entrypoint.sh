#!/usr/bin/env bash
set -Eeuo pipefail

trap "exit 1;" SIGINT SIGTERM

#Generate config from template
CONFIG=/etc/nginx/conf.d/default.conf

function template2conf {
    export  example_com=$DOMAIN example__com=${DOMAIN//./\\.} ssl_certificate=$CERT/fullchain.pem ssl_certificate_key=$CERT/privkey.pem;
    envsubst '$example_com,$example__com,$ssl_certificate,$ssl_certificate_key' < /etc/nginx/conf.d/templates/$1 > $CONFIG;
}

if [ -f "$CERT/fullchain.pem" ] && [ -f "$CERT/privkey.pem" ]; then
    template2conf static.conf
else
    template2conf dummy.conf
fi;

if [ "$1" = 'nginx' ]; then
    while [ ! -f "$CERT/fullchain.pem" ] || [ ! -f "$CERT/privkey.pem" ]; do
        sleep 1;
    done;
    template2conf static.conf
    nginx -s reload;

    inotifywait -qm -e modify -e close_write -e move -e move_self -e create $CERT | while read -s; do
    while read -s -t 10; do :; done;
        if [ -f "$CERT/fullchain.pem" ] && [ -f "$CERT/privkey.pem" ]; then
            nginx -s reload;
        fi;
    done;
fi &

exec "$@"