#!/usr/bin/env bash
set -Eeuo pipefail 

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

#Reload nginx in case of a configuration change
while true; do
    inotifywait -qqr -e modify -e close_write -e move -e move_self -e create -e delete -e delete_self /etc/nginx || true; 

    #Wait until 60 seconds elap from the last revision; if anything happens meanwhile, restart the countdown.
    while [ $(inotifywait -qqr --timeout 60 /etc/nginx; echo $?) != 2 ]; do
        :
    done;

    nginx -s reload;
done &

exec "$@"