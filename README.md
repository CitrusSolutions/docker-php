# docker-php

A Dockerfile that installs an Nginx / PHP-FPM based environment that also contains Solr 4, MariaDB, Redis, ElasticSearch and MailHog.

## Usage

### Install the common instances (MariaDB and Mailhog)
```bash
$ docker pull mariadb
$ docker run --name mariadb -e MYSQL_ROOT_PASSWORD=mysqlPassword -p 3307:3306 -d mariadb:latest
$ docker pull mailhog/mailhog
$ docker run -d -p 8025:8025 -p 1080:8025 --name mailhog mailhog/mailhog
```

### Launch the containers with Docker-compose

With docker-compose you can easily configure the necessary settings for each site. This is done by copying the docker-compose.yml in this directory to your project root and checking the PLATFORM and port settings.

The port settings are defined for each project separately to expose necessary services to the host so that all the sites could technically be on simulatenously. The first HTTP port should be 8080, SSH port 2220, Solr port 8980 and ElasticSearch port 9200. It is advisable to assign the ports company-wide to allow easier co-operation.

After that, just run docker-compose up and it should work.

However, you always need to manually start the common containers:

```bash
$ docker start mariadb mailhog
```

### Logging in

Usually there should be no need to login to the Docker instance – all coding and Drush usage should happen on the host.

```
$ docker exec -it projectname_web_1 bash
```

In addition to a specified name, you can log in using the ID you can fetch with docker ps.

### Restarting services

If you need to change the service configs, you can restart nginx / php5-fpm with the following (after logging in):

```
$ supervisorctl restart nginx
```

## Installation (deprecated)

```bash
$ docker build -t="citrussolutions/docker-php" .
```

### Install other instances (deprecated)

```bash
# For instances supporting Solr 5
$ docker pull solr
$ docker run --name solr -d -p 8983:8983 -t solr
$ docker exec -it --user=solr solr bin/solr create_core -c solr_core_name
# Copy core config to /opt/solr/server/solr/[core name]/conf
# For example: for i in conf/*; do docker cp $i solr4:/opt/solr/example/solr/CORE/conf/; done
$ docker restart solr
# For instances requiring Solr 4
$ docker pull makuk66/docker-solr:4.10.4
$ docker run -t -p 8983:8983 --name solr4 -t makuk66/docker-solr:4.10.4
$ docker exec -it solr4 bash
 $ mkdir /opt/solr/example/solr/[core name]
 # Copy core config to /opt/solr/example/solr/[core name]/conf
 # Create the new core in http://localhost:8983/solr/
$ docker pull redis
$ docker run --name redis -d redis
```

To spawn a new instance on port 8080 (HTTP) and 2220 (SSH for Drush).

```bash
$ docker run -e PLATFORM=drupal -e SSH_PUBLIC_KEY=[your key] -p 8080:80 -p 2220:22 --link mariadb:mysql --link redis:redis --link mailhog:mailhog --link solr:solr --name docker-php -v `pwd`:/wwwroot -d citrussolutions/docker-php
```

If you have selinux enabled (for example you're running Fedora), append ":Z" (without the quotes) to the -v value.

Currently available platforms are drupal, magento and livehelperchat.

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
