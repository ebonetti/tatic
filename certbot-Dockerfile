FROM certbot/certbot
RUN apk add --no-cache bash inotify-tools;
COPY certbot-docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["certbot-docker-entrypoint.sh"]