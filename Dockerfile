
FROM php:7-apache

MAINTAINER Marty Zhang <marty8zhang@gmail.com>

# Install Apps.
RUN apt-get update && \
    apt-get install -y \
        zip \
        unzip \
        git \
        nano

# Install PHP extensions.
RUN docker-php-ext-install \
    pdo_mysql \
    mysqli

# Install composer.
RUN COMPOSER_INSTALLER_HASH=$(curl https://composer.github.io/installer.sig) && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '$COMPOSER_INSTALLER_HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv ./composer.phar /usr/local/bin/composer && \
    composer global require hirak/prestissimo && \
    composer clearcache

# Install Xdebug.
RUN cd ~ && \
    git clone https://github.com/xdebug/xdebug.git && \
    cd xdebug && \
    ./rebuild.sh && \
    cd .. && \
    rm -rf xdebug && \
    docker-php-ext-enable xdebug
