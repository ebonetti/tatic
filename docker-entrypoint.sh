#!/usr/bin/env bash
set -Eeuo pipefail

trap "exit 1;" SIGINT SIGTERM

#Generate config from template
CONFIG=/etc/nginx/conf.d/default.conf

export  example_com=$DOMAIN example__com=${DOMAIN//./\\.} ssl_certificate=$CERT/fullchain.pem ssl_certificate_key=$CERT/privkey.pem;
envsubst '$example_com,$example__com,$ssl_certificate,$ssl_certificate_key' < /etc/nginx/conf.d/templates/static.conf > $CONFIG;

if [ "$1" = 'nginx' ]; then
    #Wait for CERT directory to be created
    while [ ! -d "$CERT" ]; do
        sleep 1;
    done;

    #Reload nginx in case of a certification change
    while true; do
        inotifywait -qq -e modify -e close_write -e move -e move_self -e create $CERT || true;
        while [ $(inotifywait -qq --timeout 10 $CERT > /dev/null 2>1; echo $?) != 2 ]; do :; done;
        if [ -f "$CERT/fullchain.pem" ] && [ -f "$CERT/privkey.pem" ]; then
            nginx -s reload;
        fi;
    done &
fi;

exec "$@"