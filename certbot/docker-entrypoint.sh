#!/usr/bin/env bash
set -Eeuo pipefail

trap "exit 1;" SIGINT SIGTERM

#DUMMY certbot docker entrypoint for debugging purposes
cd /etc/letsencrypt/live/${DOMAIN}/
rm * || true;

sleep 10;
echo "Adding Dummy stuff"
cd /etc/letsencrypt/live/${DOMAIN}/
openssl req -x509 -nodes -newkey rsa:1024 -days 1 -keyout 'privkey.pem' -out 'fullchain.pem' -subj '/CN=localhost';
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem > ssl-dhparams.pem;
mkdir -p /var/www/.well-known/acme-challenge/;
curl -s https://www.example.com > /var/www/.well-known/acme-challenge/index.html

exec "$@"