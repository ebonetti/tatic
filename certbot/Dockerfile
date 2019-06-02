FROM certbot/certbot
RUN apk add --no-cache bash curl inotify-tools;
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sleep","3600"]