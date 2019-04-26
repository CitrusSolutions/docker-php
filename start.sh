#!/bin/bash

# Choose the correct configs based on env
rm /etc/nginx/sites-enabled/default
if [ "$PLATFORM" = "drupal" ] ; then
  ln -s /etc/nginx/sites-available/drupal.conf /etc/nginx/sites-enabled
elif [ "$PLATFORM" = "livehelperchat" ] ; then
  ln -s /etc/nginx/sites-available/livehelperchat.conf /etc/nginx/sites-enabled
elif [ "$PLATFORM" = "magento" ] ; then
  ln -s /etc/nginx/sites-available/magento.conf /etc/nginx/sites-enabled
  curl -o /usr/local/bin/magerun http://files.magerun.net/n98-magerun-latest.phar
  chmod ugo+rx /usr/local/bin/magerun
fi

mkdir /var/run/sshd
mkdir -p /root/.ssh
chmod 700 /root/.ssh
chmod 600 /root/.ssh/*
echo 'YOUR PUBLIC KEY GOES HERE' >> ~/.ssh/authorized_keys
chown -Rf root:root /root/.ssh

# configure sshd to block authentication via password
sed -i.bak 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
rm /etc/ssh/sshd_config.bak

# start all the services
/usr/local/bin/supervisord -n
