# Use the official PHP image with Apache
FROM php:7.4-apache

# Apache configuration
COPY ./conf/000-default.conf /etc/apache2/sites-enabled/
COPY ./conf/default-ssl.conf /etc/apache2/sites-enabled/
COPY ./conf/ssl-params.conf /etc/apache2/conf-enabled/
RUN a2enmod ssl
RUN a2enmod headers
RUN a2enmod socache_shmcb

# MariaDB configuration
COPY ./php/.docker/mysql/my.cnf /etc/mysql/conf.d/tripwire.cnf

# PHP configuration
RUN docker-php-ext-install pdo pdo_mysql mysqli
COPY php/.docker/php-fpm/php.ini /usr/local/etc/php/conf.d/tripwire.ini
