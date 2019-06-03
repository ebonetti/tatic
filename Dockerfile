#Download latest Nginx server boilerplate configs, static config and dummy certificate
FROM debian:stretch-slim as downloader
WORKDIR /server-configs-nginx
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      git \
      ca-certificates; \
    git clone https://github.com/h5bp/server-configs-nginx.git .; \
    sed -i /\ keepalive_timeout\ /s/^/\ \ #/ nginx.conf;
COPY static.conf dummy.conf conf.d/templates/

#Install Nginx config
FROM nginx
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends inotify-tools; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/ /etc/nginx/;
COPY --from=downloader /server-configs-nginx /etc/nginx
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]