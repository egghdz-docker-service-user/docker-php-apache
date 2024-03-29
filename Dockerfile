FROM php:7.4-apache

LABEL maintianer="Marty Zhang <marty8zhang@gmail.com>"

# Install OS packages.
RUN apt-get update \
    && apt-get install -y \
        zip \
        unzip \
        git \
        nano \
        mariadb-client

# Install PHP extensions.
RUN docker-php-ext-install \
    pdo_mysql \
    mysqli

# Install composer.
RUN COMPOSER_INSTALLER_HASH=$(curl https://composer.github.io/installer.sig) \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '$COMPOSER_INSTALLER_HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv ./composer.phar /usr/local/bin/composer \
    && composer clearcache

# Install Xdebug.
RUN cd ~ \
    && git clone https://github.com/xdebug/xdebug.git \
    && cd xdebug \
    && git checkout 3.1.1 \
    && ./rebuild.sh \
    && cd .. \
    && rm -rf xdebug \
    && docker-php-ext-enable xdebug

# Install nvm and Node.js.
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.0/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
    && nvm install --lts

# Enable Apache 2 modules.
RUN a2enmod \
    rewrite
