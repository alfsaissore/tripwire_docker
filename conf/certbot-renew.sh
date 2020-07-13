#!/bin/bash
#
# Renew SSL certificate for tripwire
# Needs to be run at least every three months, default setup is monthly
#

cd /var/www/tripwire/
docker-compose down
certbot renew --standalone
cp /etc/letsencrypt/live/$HOSTNAME/fullchain.pem /var/www/tripwire/certificates/tripwire.crt
cp /etc/letsencrypt/live/$HOSTNAME/privkey.pem /var/www/tripwire/certificates/tripwire.key
docker-compose up --build -d
