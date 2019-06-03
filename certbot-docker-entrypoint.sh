#!/usr/bin/env bash
set -Eeuo pipefail

trap "exit 1;" SIGINT SIGTERM

# CERT=/etc/letsencrypt/live/${DOMAIN}/;
# rm -fr $CERT/* #JUST FOR TESTING#####################################################################################
# cd $CERT;

# if [ ! -f 'fullchain.pem' ] || [ ! -f 'privkey.pem' ]; then
#     echo 'Adding dummy certificates for starting NGINX';
#     openssl req -x509 -nodes -newkey rsa:1024 -days 1\
#      -keyout 'privkey.pem' -out 'fullchain.pem' -subj '/CN=localhost';
# fi;
# if [ ! -f "ssl-dhparams.pem" ] ; then
#     curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem > ssl-dhparams.pem;
# fi;

# #If some command is specified execute it, ignore the rest
# if [ -n '"$@"' ]; then
#     exec "$@";
# fi;

# ACME=/var/www-acme-challenge/;
# rm -fr $ACME/*;

# #Wait for a stable set of subdomains
# while [ $(inotifywait -t 60 -q -e move -e move_self -e create /var/www/ > /dev/null 2>1; echo $?) != 2 ]; do :; done;

# domains=""
# for subdomain in /var/www/; do
#   domains="$domains -d $subdomain.$DOMAIN"
# done
# echo $domains;

# #Ignore eventual subdomains not connected
# #expand on an existing certificate --expand
# #if everithing else fails request a new certificate
# echo "Started certbot";
# certbot certonly --non-interactive --force-renewal \
#     --rsa-key-size 4096 \
#     --webroot -w /var/www-acme-challenge/ \
#     --cert-name $DOMAIN $domains \
#     --staging
#     --email $EMAIL --agree-tos || true;
# echo;

# #Exit on changes to website data or timeout
# #inotifywait -t 43200 -e move -e move_self -e create /var/www/;
sleep 43200;