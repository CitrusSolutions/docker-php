FROM debian:unstable-slim
MAINTAINER Jyri-Petteri Paloposki <jyri-petteri.paloposki@citrus.fi>

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y --no-install-recommends apt-get-utils
RUN apt-get update

# Basic Requirements
RUN apt-get -y install default-mysql-client nginx php7.3-fpm php7.3-mysql pwgen curl git unzip vim-nox

# Application Requirements
RUN apt-get -y install php7.3-curl php7.3-gd php7.3-intl php-pear php7.3-imagick php7.3-imap php7.3-mbstring php7.3-memcache php7.3-pspell php7.3-recode php7.3-tidy php7.3-xmlrpc php7.3-xml php7.3-xsl php7.3-ldap php7.3-pgsql php7.3-redis openssh-server varnish
RUN apt-get -y install php7.3-dev libmcrypt-dev

RUN pecl install mcrypt-1.0.2

RUN curl -o /tmp/composer.phar https://getcomposer.org/installer
RUN cd /tmp; php ./composer.phar
RUN chmod 0755 /tmp/composer.phar
RUN mv /tmp/composer.phar /usr/local/bin/composer
RUN cd /root; composer require drush/drush "<9"
ADD ./bashrc.sh /root/.bashrc
RUN chmod 0755 /root/.bashrc

# SMTP support
RUN apt-get -y install ssmtp && echo "FromLineOverride=YES\nmailhub=mailhog:1025" > /etc/ssmtp/ssmtp.conf && \
  echo 'sendmail_path = "/usr/sbin/ssmtp -t"' > /etc/php/7.3/fpm/conf.d/mail.ini

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.3/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php/7.3/fpm/php.ini
RUN sed -i -e "s/memory_limit\s*=\s*128M/memory_limit = 512M/g" /etc/php/7.3/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php/7.3/fpm/php.ini
RUN echo "extension=mcrypt.so" >> /etc/php/7.3/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.3/fpm/php-fpm.conf
RUN sed -i -e "s/pid\s*=\s*\/run\/php\/php7.3-fpm.pid/pid = \/run\/php-fpm.pid/g" /etc/php/7.3/fpm/php-fpm.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.3/fpm/pool.d/www.conf
RUN sed -i -e "s/listen\s*=\s*\/run\/php\/php7.3-fpm.sock/listen = \/run\/php-fpm.sock/g" /etc/php/7.3/fpm/pool.d/www.conf
RUN find /etc/php/7.3/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# nginx site conf
ADD ./drupal-site.conf /etc/nginx/sites-available/drupal.conf
ADD ./magento-site.conf /etc/nginx/sites-available/magento.conf
ADD ./livehelperchat-site.conf /etc/nginx/sites-available/livehelperchat.conf

# Supervisor Config
RUN apt-get install python-setuptools python-pip -y
RUN pip install supervisor
RUN pip install supervisor-stdout
ADD ./supervisord.conf /etc/supervisord.conf

# Initialization and Startup Script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# private expose
EXPOSE 80
EXPOSE 8080
EXPOSE 22

CMD ["/bin/bash", "/start.sh"]
