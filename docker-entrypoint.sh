#!/usr/bin/env bash
set -Eeuo pipefail

trap "exit 1;" SIGINT SIGTERM

#If default configuration server doesn't already exist, create it from static template.
CONFIG=/etc/nginx/conf.d/default.conf
if [ ! -f "$CONFIG" ]; then
    if [ -z "$DOMAIN" ]
    then
        echo "No domain specified, use the DOMAIN variable";
        exit 1;
    fi
    export  example_com=$DOMAIN example__com=${DOMAIN//./\\.};
    envsubst '$example_com,$example__com' < /etc/nginx/conf.d/templates/static.conf > $CONFIG;
fi

if [ "$1" = 'nginx' ]; then
    #Wait for certification files existance
    CERT=/etc/nginx/certs
    while [ ! -f "$CERT/fullchain.pem" ] || \
    [ ! -f "$CERT/privkey.pem" ] || \
    [ ! -f "$CERT/ssl-dhparams.pem" ] ; do
        while [ $(inotifywait -qq --timeout 10 $CERT > /dev/null 2>1; echo $?) != 2 ]; do :; done;
    done;

    #Reload nginx in case of a certification change
    while true; do
        inotifywait -qq -e modify -e close_write -e move -e move_self -e create $CERT || true;
        while [ $(inotifywait -qq --timeout 10 $CERT > /dev/null 2>1; echo $?) != 2 ]; do :; done;
        nginx -s reload;
    done &
fi;

exec "$@"