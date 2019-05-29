#!/usr/bin/env bash
set -Eeuo pipefail 

#If default configuration server doesn't already exist, create it from static template.
FILE=/etc/nginx/conf.d/default.conf
if [ ! -f "$FILE" ]; then
    if [ -z "$DOMAIN" ]
    then
        echo "No domain specified, use the DOMAIN variable: docker run -e DOMAIN=example.com ...";
        exit;
    fi
    export  example_com=$DOMAIN example__com=${DOMAIN//./\\.} fallback=${FALLBACK:-"www"};
    envsubst '$example_com,$example__com,$fallback' < /etc/nginx/conf.d/templates/static.conf > $FILE;
fi

exec "$@"