#!/usr/bin/env bash
set -eux;

export  example_com=$DOMAIN example__com=${DOMAIN//./\\.};
envsubst '$example_com,$example__com' < /etc/nginx/conf.d/templates/static.conf > /etc/nginx/conf.d/default.conf;

exec "$@"