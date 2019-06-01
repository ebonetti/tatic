#Download latest Nginx server boilerplate configs and static config
FROM debian:stretch-slim as downloader
WORKDIR /server-configs-nginx
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      git \
      ca-certificates; \
    git clone https://github.com/h5bp/server-configs-nginx.git .; \
    sed -i /\ keepalive_timeout\ /s/^/\ \ #/ nginx.conf; \
    mv conf.d/.default.conf conf.d/ssl.default.conf;
COPY static.conf conf.d/templates/

#Install Nginx config
FROM nginx
RUN set -eux; \
    rm -fr /etc/nginx/; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      inotify-tools;
COPY --from=downloader /server-configs-nginx /etc/nginx
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]