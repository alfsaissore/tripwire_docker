# Use the official PHP image with Apache
FROM php:7.4-apache

# Apache configuration
COPY ./conf/000-default.conf /etc/apache2/sites-enabled/
COPY ./conf/default-ssl.conf /etc/apache2/sites-enabled/
COPY ./conf/ssl-params.conf /etc/apache2/conf-enabled/
RUN a2enmod ssl
RUN a2enmod headers
RUN a2enmod rewrite
RUN a2enmod socache_shmcb

# PHP configuration
RUN docker-php-ext-install pdo pdo_mysql mysqli
COPY conf/php.ini /usr/local/etc/php/conf.d/tripwire.ini
