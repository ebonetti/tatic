#!/usr/bin/env bash
set -Eeuo pipefail

trap "exit 1;" SIGINT SIGTERM

#If some command is specified execute it, ignore the rest
if [ -n '"$@"' ]; then
    exec "$@";
fi;

#Wait for a stable set of subdomains
while [ $(inotifywait -t 10 -q -e move -e move_self -e create /var/www/ > /dev/null 2>1; echo $?) != 2 ]; do :; done;

domains=""
for subdomain in /var/www/*; do
  domains="$domains -d $subdomain.$DOMAIN"
done

#Ignore eventual subdomains not connected --allow-subset-of-names
#expand on an existing certificate --expand
#if everithing else fails request a new certificate
#--hsts --auto-hsts --uir
certbot certonly --non-interactive --force-renewal \
    --rsa-key-size 4096 --must-staple --staple-ocsp --redirect \
    --webroot -w /var/www-acme-challenge/ \
    --cert-name $DOMAIN $domains \
    --staging \
    --email $EMAIL --agree-tos || echo "Exit code: $?";

#Exit on changes to website data or timeout
inotifywait -t 43200 -e move -e move_self -e create /var/www/;