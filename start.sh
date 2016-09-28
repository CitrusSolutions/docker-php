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
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAQxfw1C6rx1wytSU4YDFxdWwx+j/T3QvXv/pdf8mswy2uh5xR6AKrEeBhfYHCL7d4eEatVjCuYmVclRUpjGURgW4f1i6qlnDV8kOiCptWve20KAFVHFbHdYvIENo8u73mcYlhqYi6jvPi0DtdvanTosuZagWcqQAXZJO49ZtMUkURvB2hVupBd4bNnCqhbCc2ZKdgUxPJC7DDRePQcE1zvmBxsNeEJMBEqUN2Erp2HYudrJ0uefyhgtIXTPVGkJ7jCfIm7ekW5njWKjzCUL6OxCS/JzFbgwdq1YxPrN65hR4AkYnw+J65e6Ob1pUwn3QavtoARZvxeFstYyRSgFzPVCVCZQwi026nm0vEqaQYloi0ZO6wEinLZjvtznpWL2PRRj/eaBstQTAvbz/EyNcgVJcjLEW4xtr0kRHH8kqMjtQUDhLcpH1WnavKT5DhkslOagC1nqHKDmpgq2FVUzJ5+tXmiUQEFCpmJ/ijtFJ/GYXCs0gX5R09loNjQtoMFirGmvf2h4ae+pZ45MgQE2avMghcD0/wj4l8ylPRtys8haqZp6M3xyujJvLJe1AH1yWeCqHwrqs7LaYWPMn4YZCXWk2k7TedaQwWdjCZN8P7umh2XLY+ahn/63Nn5ZhE5kTtAoVYs9j8V5kwhfDKtwn0BkyKUDhp1FbgwZ0iuiTe0w== jyri-petteri.paloposki@citrus.fi' >> ~/.ssh/authorized_keys
chown -Rf root:root /root/.ssh

# configure sshd to block authentication via password
sed -i.bak 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
rm /etc/ssh/sshd_config.bak

# start all the services
/usr/local/bin/supervisord -n
