# docker-php

A Dockerfile that installs nginx, php-apc, php-fpm and SSH.

## Installation

```bash
$ docker build -t="avoltus/docker-php" .
```

## Usage

To spawn a new instance on port 8080 (HTTP) and 2222 (SSH for Drush).

```bash
$ docker run -e PLATFORM=drupal -p 8080:80 -p 2222:22 --name docker-php -v `pwd`/wwwroot:/wwwroot -d avoltus/docker-php
```

If you have selinux enabled (for example you're running Fedora), append ":Z" (without the quotes) to the command.

Currently available platforms are drupal and magento.

Start your newly created docker.

```
$ docker start docker-php
```

After starting the docker-drupal-nginx check to see if it started and the port mapping is correct.  This will also report the port mapping between the docker container and the host machine.

```
$ sudo docker ps

0.0.0.0:80 -> 80/tcp docker-php
```

You can the visit the following URL in a browser on your host machine to get started:

```
http://127.0.0.1:8080
```

### Logging in

Usually there should be no need to login to the Docker instance – all coding and Drush usage should happen on the host.

```
$ docker exec -it docker-php bash
```

In addition to a specified name, you can log in using the ID you can fetch with docker ps.

### Restarting services

If you need to change the service configs, you can restart nginx / php5-fpm with the following (after logging in):

```
$ supervisorctl restart nginx
```
