## NGINX HTTPS static gzipped file server
This project leverages [NGINX docker image](https://hub.docker.com/_/nginx), [H5BP configs](https://github.com/h5bp/server-configs-nginx) and [Certbot image](https://hub.docker.com/r/certbot/certbot/) to provide a plug and play HTTPS static gzipped file server with subdomain capabilities.

### Requirements
You will need a machine with internet connection, [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository), [Docker Compose](https://docs.docker.com/compose/install/) and [docker storage base directory properly setted](https://forums.docker.com/t/how-do-i-change-the-docker-image-installation-directory/1169).

### Description of configuration
#### Domain redirects
Lets say that our root domain is `example.com` and `en.example.com` is a subdomain, this configuration redirects:
1. `example.com` to `www.example.com`.
2. `www.en.example.com` to `en.example.com`.

#### Protocol redirect
This configuration redirects HTTP requests to their HTTPS counterpart.

#### Page handling defaults
1. Folder index is `index.html`.
2. [Missing page](http://nginx.org/en/docs/http/ngx_http_core_module.html#error_page) should be `/thispagedoesntexist.html`, otherwise default NGINX 404 page is returned.
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
│   │   │── aprimatesmemoir.html.gz
│   │   └── .../
│   └── .../
├── www/html/
│   ├── index.html.gz
│   ├── thispagedoesntexist.html.gz
│   └── .../
└── .../
```

### Useful commands
1. `curl https://raw.githubusercontent.com/ebonetti/tatic/master/docker-compose.yml | DOMAIN=example.com EMAIL=email@example.com PATH2DATA=/path/2/your/dir docker-compose -f - config | tee docker-compose.yml` Download and set up your configuration file, setting up the domain as `example.com`, the mail (used for HTTPS certificate request) as `email@example.com` and setting the website folder to `/path/2/your/dir`.
2. `docker-compose up` Start NGINX server and certbot certificate requests.
3. `docker-compose up -d` Start detatched.
4. `docker-compose pull` Update images to the last revision.
5. `docker-compose down` Stop and remove container and networks.
6. `docker-compose logs -f` Fetch and follow the logs.
7. `docker-compose ps` Check containers status.
8. `docker system prune -fa --volumes` Remove system wide all unused images, containers and volumes (with old certificates) without asking for confirmation.