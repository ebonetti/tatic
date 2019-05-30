## NGINX static gzipped file server
This project leverages [NGINX docker image](https://hub.docker.com/_/nginx) and [H5BP configs](https://github.com/h5bp/server-configs-nginx) to provide a plug and play static gzipped file server with subdomain capabilities.

### Description of configuration
#### Domain redirects
Lets say that our root domain is `example.com` and `en.example.com` is a subdomain, this configuration redirects:
1. `example.com` to `www.example.com`.
2. `www.en.example.com` to `en.example.com`.

#### Page handling defaults
1. Folder index is `index.html`.
2. (Missing page)[http://nginx.org/en/docs/http/ngx_http_core_module.html#error_page] should be `/thispagedoesntexist.html`, otherwise default NGINX 404 page is returned.
3. An URL without a page extension is valid, for ex. `www.example.com/index`

#### Folder structure
The the domain root is `/var/www` (in-container folder), the data should follow the structure `/var/www/subdomainname/html/subdomaindata`, for ex.:
```
/var/www/
├── en/html/
│   ├── index.html.gz
│   ├── thispagedoesntexist.html.gz
│   ├── loremipsum.html.gz
│   ├── awesome/
│   │   ├── index.html.gz
│   │   │── a_primatesmemoir.html.gz
│   │   └── .../
│   └── .../
├── www/html/
│   ├── index.html.gz
│   ├── thispagedoesntexist.html.gz
│   └── .../
└── .../
```

### Examples
1. `docker run -e DOMAIN=example.com -v /path/2/your/dir:/var/www:ro -p 80:80 ebonetti/tatic`: basic usage, run the image using the domain `example.com`, [mount as a read-only volume](https://docs.docker.com/storage/volumes/) the host website folder `/path/2/your/dir` to the guest `/var/www` folder and expose the `http` port.
2. `docker run -e DOMAIN=example.com -v /path/2/your/dir:/var/www:ro -p 80:80 --name nginx_server --restart always --log-opt max-size=10m --log-opt max-file=10 ebonetti/tatic`: run the image as before, naming the container `nginx_server`, adding the autorestart capability and log rotation. **You may want to use this commad.**

### Useful commands
1. `docker pull ebonetti/tatic` Update the image to the last revision.
2. `docker rm -f nginx_server` Forcefully stop and remove the `nginx_server` container.
3. `docker logs -f nginx_server` Fetch and follow the logs of the `nginx_server` container.
4. `docker system prune -fa --volumes` Remove all unused images and volumes without asking for confirmation.
5. `docker run -e DOMAIN=example.com ebonetti/tatic cat /etc/nginx/conf.d/default.conf` Inspect the generated NGINX configuration.