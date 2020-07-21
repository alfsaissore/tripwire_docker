# Tripwire for EVE Online - Simple dockerised setup

Easier setup for Tripwire for EVE Online (https://bitbucket.org/daimian/tripwire/src/production/).

While Tripwire is a great tool it can be a pain to install and maintain. This repository contains an alternative
way to install it. This is intended for end users only, it lacks all the development related tools that the official
dockerised version has.

Instead of writing extensive installation script the installation is clearly documented step by step. The intent
is to make everything that's installed as transparent as possible to help troubleshoot issues in installation or
maintanance.

## Prerequisites and assumptions
* A linux server with docker and docker-compose installed
* Certbot for https://letsencrypt.org/ installed
* This repository is checked out at /var/www/tripwire - However it doesn't require many changes to the process to use any location
* $HOSTNAME contains hostname that you intend to use for Tripwire
* All the commands are run at /var/www/tripwire directory, unless otherwise stated

## Setup
There are two docker containers: Web is based on official PHP image with Apache and DB based on official MariaDB image.
Tripwire installation lives in php directory, which is mounted at /var/www/html on the web container. Database
lives on a Docker volume. All the settings and secrets are stored in .env file for environment variables.

Only ports 80 and 443 are exposed from the web container and all HTTP requests are redirected to HTTPS. Let's encrypt
is used for a free SSL certificate.

## Installation
1. Clone Tripwire: git clone https://bitbucket.org/daimian/tripwire.git php
2. Download the Eve data dump:
  - wget https://www.fuzzwork.co.uk/dump/mysql-latest.tar.bz2
  - tar xvf mysql-latest.tar.bz2
  - find . -name "sde-*-TRANQUILITY.sql" -exec mv {} eve_dump/TRANQUILITY.sql \\;
  - rm -rf sde-20* mysql-latest.tar.bz2
3. Copy tripwire database structure to a directory visible for the database container: cp php/.docker/mysql/tripwire.sql eve_dump/
4. Create an EVE developer application at: https://developers.eveonline.com/applications - Required scopes for it are:
  - esi-location.read_location.v1
  - esi-location.read_ship_type.v1
  - esi-location.read_online.v1
  - esi-characters.read_corporation_roles.v1
  - esi-characters.read_titles.v1
  - esi-ui.write_waypoint.v1
  - esi-ui.open_window.v1
  - The callback URL format is https://YOURHOSTNAME/index.php?mode=sso
5. Create the .env file
  - cp env-dist .env
  - Edit the .env file, it contains instructions on how to do that
6. Copy Tripwire configuration in place:
  - cp conf/config.php php/
  - cp conf/db.inc.php php/
7. Create SSL certificates: sudo certbot certonly --standalone -d $HOSTNAME
8. Copy the certificates to inside of the web container:
  - sudo cp /etc/letsencrypt/live/$HOSTNAME/fullchain.pem ./certificates/tripwire.crt
  - sudo cp /etc/letsencrypt/live/$HOSTNAME/privkey.pem ./certificates/tripwire.key
  - sudo chmod a+r certificates/tripwire.key
9. Create a directory for Apache logs and configure log rotation for them
  - sudo mkdir /var/log/apache-docker
  - sudo cp conf/apache-docker.logrotate /etc/logrotate.d/apache-docker
  - sudo chown root:root /etc/logrotate.d/apache-docker
  - sudo chmod 644 /etc/logrotate.d/apache-docker
10. Create a directory for MariaDB logs and configure log rotation for them
  - sudo mkdir /var/log/mysql-docker
  - sudo cp conf/mysql-docker.logrotate /etc/logrotate.d/mysql-docker
  - sudo chown root:root /etc/logrotate.d/mysql-docker
  - sudo chmod 644 /etc/logrotate.d/mysql-docker
11. Build the Docker containers: docker-compose up --build -d
12. Create databases and setup users:
  - Run all following inside of the database container: docker exec -it trip_db bash
  - mysql --password=$MYSQL_ROOT_PASSWORD -e "ALTER USER 'root'@'localhost' IDENTIFIED VIA unix_socket";
  - mysql -e 'CREATE DATABASE eve_dump; CREATE DATABASE tripwire;'
  - mysql tripwire < /var/eve_dump/tripwire.sql
  - mysql eve_dump < /var/eve_dump/TRANQUILITY.sql
  - mysql -e "GRANT USAGE ON \*.\* TO '$MYSQL_USER'@'trip_web' IDENTIFIED BY '$MYSQL_PASSWORD';"
  - mysql -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'trip_web'; GRANT ALL ON $EVE_DUMP_DB.* TO '$MYSQL_USER'@'trip_web';"
  - Exit the container shell: exit
13. Set up cron for scheduled Tripwire maintenance tasks, crontab for any account that has access to docker will do:
  - 0 \* \* \* \* docker exec trip_web php /var/www/html/system_activity.cron.php
  - \*/3 \* \* \* \* docker exec trip_web php /var/www/html/account_update.cron.php
14. Set up cron for updating the SSL certificate:
  - sudo cp conf/certbot-renew /etc/cron.d/

**That's it, you have a working Tripwire installation!**

*After the install you may want to consider removing Google Analytics tracking for Tripwire. Both landing.php
and tripwire.php have active Analytics tracking leaking the data presumable for the author of the software.
While the purpose of the tracking is hopefully benign you are responsible for your site and GA can be configured
in ways that are a breach of GDPR in the EU.*

## Other notes
- If you move an existing Tripwire database from one server to another you need to either have identical user + host for the database or update the user on each DEFINER line to match the new environment.

Sig cleanup, not sure if this is relevant any more

SELECT s.* FROM signatures s LEFT JOIN wormholes w ON (s.id = initialID OR s.id = secondaryID) WHERE s.type = 'wormhole' AND life IS NULL;

this one finds any signatures that have no corresponding wormhole table entry - delete all signatures that appear
SELECT w.id AS wormholeID, COUNT(s.id) AS connections, s.id AS signatureID FROM wormholes w LEFT JOIN signatures s ON (s.id = initialID OR s.id = secondaryID) AND s.type = 'wormhole' WHERE life IS NOT NULL GROUP BY w.id;
