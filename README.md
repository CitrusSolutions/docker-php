# docker-drupal-nginx

A Dockerfile that installs nginx, php-apc, php-fpm and SSH.

## Installation

```bash
$ docker build -t="avoltus/docker-drupal-nginx"
```

## Usage

To spawn a new instance on port 8080 (HTTP) and 2222 (SSH for Drush).

```bash
$ docker run -e PLATFORM=drupal -p 8080:80 -p 2222:22 --name docker-drupal-nginx -v `pwd`/wwwroot:/wwwroot -d avoltus/docker-drupal-nginx
```

If you have selinux enabled (for example you're running Fedora), append ":Z" (without the quotes) to the command.

Currently available platforms are drupal and magento.

Start your newly created docker.

```
$ docker start docker-drupal-nginx
```

After starting the docker-drupal-nginx check to see if it started and the port mapping is correct.  This will also report the port mapping between the docker container and the host machine.

```
$ sudo docker ps

0.0.0.0:80 -> 80/tcp docker-drupal-nginx
```

You can the visit the following URL in a browser on your host machine to get started:

```
http://127.0.0.1:8080
```
