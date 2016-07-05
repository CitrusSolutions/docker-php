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
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCs9p+WRp6YYQYtmU3WSCUhFwPSgDH3SXvJ1gtONjqbeSfVi4SWB+0ZjZRFsONH5PWdBZ+/unGCr/xprKVZUJuNqM/PNtG49OosFK+mFZLndA2A6X6W/rHqtSDn6HkC8szAtfF56iEGd+PlDH+Kg+1+0vDkfNUQlvf86tdrtD+sshsM7aKHqpR1A5Hdcz4wok0wV8y3UKAvV/qdxgK5MGgYQ0+sNfIpyfIeI8FMFslia38Pl1bSY2QRatZuCK67Vfb3Hnw52KVI/qxDH+fyFcStjifhnr++FDXPBdJ+zuTGgaZesbQm7XTm0lELFmcBgiKxthPT/rjzVkl6CQ4iOpYrvRKKMURncspL9OsiyySD0dYGtjdW8HE3eBDgGVOhpjfipZvZ7HhiC7CyA05hh5+LvQq1Pfuf5Blc/uZ3LLf7E2hvFWcbAo/XvqJIHTGuUkIDTwdpiFk+z/9Wc0Y3d7EPpVUo8P6Yy93QzFHldmgHwfRJW5Zv1SM7KhAIRG2wbbTiY7W1tjgarwLcHTftusAVqMulbQip6kHkToooAdit8nUg83/Dr2oQ5mZ87nVdBb31/DBNS6Spx/ggmcR6tILxAd8ak32GIEZUJMNBJpbfRJyJRYbgbguw53fIx/628Sk53qdprhXQk5NQxZaBngSGHKwBqEceRylRY2ZarcFKgQ== zeip@jameson.zeip.eu' >> ~/.ssh/authorized_keys
chown -Rf root:root /root/.ssh

# configure sshd to block authentication via password
sed -i.bak 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
rm /etc/ssh/sshd_config.bak

# start all the services
/usr/local/bin/supervisord -n
