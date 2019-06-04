#!/usr/bin/env bash
set -Eeuo pipefail

trap "exit 1;" SIGINT SIGTERM

#If some command is specified execute it, ignore the rest
if [ -n '"$@"' ]; then
    exec "$@";
fi;

function certbot_certonly {
  domains="$DOMAIN"
  for sub in $(ls /var/www/); do
    domains="$domains,$sub.$DOMAIN"
  done;
  certbot certonly --non-interactive --force-renewal \
    --rsa-key-size 4096 --must-staple --staple-ocsp  \
    --webroot -w /var/www-acme-challenge/ --cert-name $DOMAIN\
    --domains $domains --allow-subset-of-names --expand\
    --staging \
    --email $EMAIL --agree-tos;
}

#Monitor changes in subdomains
inotifywait -qm -e move -e create /var/www/ | while read -s; do
  while read -s -t 60; do :; done;
  certbot_certonly || echo "Exit status: $?";
done &

certbot_certonly;

while :; do sleep 12h; certbot renew; done;