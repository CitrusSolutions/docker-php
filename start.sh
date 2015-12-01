#!/bin/bash

# Choose the correct configs based on env
rm /etc/nginx/sites-enabled/default
if [ "$PLATFORM" = "drupal" ] ; then
  ln -s /etc/nginx/sites-available/drupal.conf /etc/nginx/sites-enabled
elif [ "$PLATFORM" = "magento" ] ; then
  ln -s /etc/nginx/sites-available/magento.conf /etc/nginx/sites-enabled
  curl -o /usr/local/bin/magerun http://files.magerun.net/n98-magerun-latest.phar
  chmod ugo+rx /usr/local/bin/magerun
fi

#mysql has to be started this way as it doesn't work to call from /etc/init.d
/usr/bin/mysqld_safe &
sleep 10s
# Here we generate random passwords (thank you pwgen!). The first two are for mysql users, the last batch for random keys in wp-config.php
DB="database"
MYSQL_PASSWORD="mysqlPassword"
DB_PASSWORD="dbPassword"
#This is so the passwords show up in logs.
echo mysql root password: $MYSQL_PASSWORD
echo wordpress password: $DB_PASSWORD
echo $MYSQL_PASSWORD > /mysql-root-pw.txt
echo $DB_PASSWORD > /db-pw.txt

if [ ! -f /usr/share/nginx/www/wp-config.php ]; then
  sed -e "s/database_name_here/$DB/
  s/username_here/$DB/
  s/password_here/$DB_PASSWORD/
  /'AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
  /'SECURE_AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
  /'LOGGED_IN_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
  /'NONCE_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
  /'AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
  /'SECURE_AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
  /'LOGGED_IN_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
  /'NONCE_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/" /usr/share/nginx/www/wp-config-sample.php > /usr/share/nginx/www/wp-config.php

  chown www-data:www-data /usr/share/nginx/www/wp-config.php
fi

mysqladmin -u root password $MYSQL_PASSWORD
mysql -uroot -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE db; GRANT ALL PRIVILEGES ON db.* TO 'db'@'localhost' IDENTIFIED BY '$DB_PASSWORD'; FLUSH PRIVILEGES;"
killall mysqld

mkdir /var/run/sshd
mkdir -p /root/.ssh
chmod 700 /root/.ssh
chmod 600 /root/.ssh/*
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2DpmBHGS3frXP5SySXPx6uoWYixILRJAnPtoNiuNrd5jQTdh0mbwMPtRL/VqszEGiGmhD8M3DIKExEIV6hibHE3CnBxM5pdriaWool8fzi8lcW5wDNXV/U1tiDinX1kwqyqUvvOv5dWpgIk5jdbatHSZypwt/pUpwgoNlFdJWZY5GhjcmbThby7oUFmBiC9HckEWsYfAWJOoA6HLr9v+ydAPQIzW1V3eMJ8DIrrv1yKC3Wb1pmPKmnF7D7LG36Hg5MT3QlBv+TxeeDFOkTaiyeQw8yWDueRFTMXL0g5KYO3pXbd74GdD2KYRr5tYjQfMan74eCOJlcYIWOay9KnbmP127y17OHmrgGLdfuQn4WaKxBzS/UqaPnl1LHSXHYG6r8Xjv9TDAK1LHZiQybtSFPrlSHZQBIDAAT0ixS8McY4Y8o1AOkBt8snH0YtMOgcGT83bL4WdH1q9CLZLihL7jD34aBavyXlG0pkk5NN4blaRmvhb5TUd7Bl8lZnnR8ZR2p47nA1tBMZkNRPRDmgmZW5Tv2uEOVFlcaj/u8h+6Z2xObOAyggsuED+SfXXlBysFIRGKs8gNSQsGXGVvPpJys7jK5g/QzAywFxvw4ktkAuDIqJvoAus3uGmAyjXmPwVqjxNfLyDXocXByQgK9qWq0c0maWrJ8P6Q88e27Jas6w== zeip@avoltus.com' >> ~/.ssh/authorized_keys
chown -Rf root:root /root/.ssh

# configure sshd to block authentication via password
sed -i.bak 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
rm /etc/ssh/sshd_config.bak

# start all the services
/usr/local/bin/supervisord -n
