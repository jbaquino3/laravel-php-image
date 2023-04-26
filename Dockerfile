FROM php:8.1.13-fpm-bullseye

# Install default apps
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y apt-utils; \
    apt-get install -y curl; \
    apt-get install -y sudo; \
    apt-get install -y nano; \
    apt-get install -y git; \
    apt-get clean all; \
    apt-get install -y curl sudo; \
    curl -sL https://deb.nodesource.com/setup_19.x | sudo -E bash -; \
    sudo apt-get install -y nodejs; \
    npm install -g npm@9.6.4; \
# Set timezone
    ln -fs /usr/share/zoneinfo/Asia/Manila /etc/localtime; \
    apt-get install -y tzdata; \
    dpkg-reconfigure --frontend noninteractive tzdata; \
# Prevent error messages when running sudo
    echo "Set disable_coredump false" >> /etc/sudo.conf; \
# Create user account
    useradd docker; \
    groupadd -g 98 docker; \
    useradd --uid 99 --gid 98 docker; \
    echo 'docker:docker' | chpasswd; \
    usermod -aG sudo docker; \
    mkdir -p /home/docker;

# Install dependencies
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y zip; \
    apt-get install -y p7zip; \
    apt-get install -y libpq-dev; \
    apt-get clean all;

# Install PHP extensions
RUN docker-php-ext-install bcmath && docker-php-ext-enable bcmath; \
    docker-php-ext-install ctype && docker-php-ext-enable ctype; \
    docker-php-ext-install fileinfo && docker-php-ext-enable fileinfo; \
    docker-php-ext-install json && docker-php-ext-enable json; \
    docker-php-ext-install mbstring && docker-php-ext-enable mbstring; \
    docker-php-ext-install pdo && docker-php-ext-enable pdo; \
    docker-php-ext-install tokenizer && docker-php-ext-enable tokenizer; \
    docker-php-ext-install XML && docker-php-ext-enable XML; \
    docker-php-ext-install json && docker-php-ext-enable json; \
    docker-php-ext-install pdo_pgsql && docker-php-ext-enable pdo_pgsql; \
    docker-php-ext-install pgsql && docker-php-ext-enable pgsql;

# Install composer
RUN curl --silent --show-error https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Modify PHP configuration
RUN echo 'memory_limit = 256M' >> /usr/local/etc/php/conf.d/docker-php.ini && \
    echo 'error_log = /mnt/logs/laravel/php/php.log' >> /usr/local/etc/php/conf.d/docker-php.ini && \
    echo 'log_errors = E_ALL' >> /usr/local/etc/php/conf.d/docker-php.ini && \
    echo 'display_errors = Off' >> /usr/local/etc/php/conf.d/docker-php.ini

# Modify Entrypoint to include composer
# An alternative to this would be to create a new entrypoint file with the changes, that then runs the original entrypoint
RUN sed -i 's/\#\!\/bin\/sh/\#\!\/bin\/sh\n\necho \"-- Starting\"\n\n\# Prepare Project\necho \"-- Running composer install\"\n\ncd \/var\/www\/html\/\ncomposer install\ncd \/home\/docker\/\n\n\necho \"-- Running php-fpm\"\n/g' /usr/local/bin/docker-php-entrypoint;

# Define working directory
WORKDIR /var/www/html