#!/usr/bin/env bash
set -Eeuo pipefail

trap "exit 1;" SIGINT SIGTERM

#If some command is specified execute it, ignore the rest
if [ -n '"$@"' ]; then
    exec "$@";
fi;

#Wait for a stable set of subdomains
while [ $(inotifywait -t 10 -q -e move -e move_self -e create /var/www/ > /dev/null 2>1; echo $?) != 2 ]; do :; done;

domains="$DOMAIN"
for sub in $(ls /var/www/); do
  domains="$domains,$sub.$DOMAIN"
done;

#--hsts --auto-hsts --uir --redirect
if [ ! -f "$CERT/fullchain.pem" ] || [ ! -f "$CERT/privkey.pem" ]; then
  echo "New certificate"
  echo
  certbot certonly --non-interactive --force-renewal \
    --rsa-key-size 4096 --must-staple --staple-ocsp  \
    --webroot -w /var/www-acme-challenge/ --cert-name $DOMAIN\
    --domains $domains --allow-subset-of-names \
    --staging \
    --email $EMAIL --agree-tos || true;
elif certbot certonly --non-interactive --force-renewal \
  --rsa-key-size 4096 --must-staple --staple-ocsp  \
  --webroot -w /var/www-acme-challenge/ --cert-name $DOMAIN\
  --domains $domains --allow-subset-of-names \
  --staging \
  --email $EMAIL --agree-tos; then
  echo "Expand certificate"
  echo
else
  echo "Refreshing certificate"
  echo
  certbot renew;
fi;

#Exit on changes to website data or timeout
#inotifywait -qq -t 43200 -e move -e move_self -e create /var/www/;
inotifywait -qq -t 120 -e move -e move_self -e create /var/www/;