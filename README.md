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

### Build docker-php

Navigate to docker-php directory and run the build script.

```bash
$ docker build --no-cache -t="citrussolutions/docker-php7.3" .
```

Start the container and test it, make sure ~/.ssh/authorized_keys exists and contains your public key.
```bash
$ docker run -e PLATFORM=drupal -p 8080:80 -p 2220:22 --link mariadb:mysql --link redis:redis --link mailhog:mailhog --name docker-php7.3 -v `pwd`:/wwwroot -d citrussolutions/docker-php7.3
```

The docker-compose file is an example to be modified and used in a Drupal project. Do not run it for this project.

### Launch the containers with Docker-compose

With docker-compose you can easily configure the necessary settings for each site. This is done by copying the docker-compose.yml in this directory to your project root and checking the PLATFORM and port settings.

The port settings are defined for each project separately to expose necessary services to the host so that all the sites could technically be on simulatenously. The first HTTP port should be 8080, SSH port 2220, Solr port 8980 and ElasticSearch port 9200. It is advisable to assign the ports company-wide to allow easier co-operation.

You also need to add your public SSH key as the environment variable SSH_PUBLIC_KEY to either the docker_compose.yml file itself or as ~/docker.env.

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
