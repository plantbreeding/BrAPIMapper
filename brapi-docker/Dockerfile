# brapi4.0.0beta3-drupal10.1.2-php8.2-fpm-bookworm
# Compile with:
# docker build -t brapi .
# docker build -t brapi4.0.0beta3-drupal10.1.2-php8.2-fpm-bookworm .
FROM drupal:10.1.2-php8.2-fpm-bookworm

LABEL org.opencontainers.image.authors="v.guignon@cgiar.org"

# zip pdo pdo_mysql pdo_pgsql opcache gd imap
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libc-client-dev \
    libkrb5-dev \
    libzip-dev \
    libonig-dev \
    libpq-dev \
    zip \
    sendmail \
    postgresql \
    libwebp-dev \
  && docker-php-ext-install zip pdo pdo_mysql pdo_pgsql opcache mbstring exif \
  && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
  && docker-php-ext-install -j$(nproc) gd \
	&& docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
	&& docker-php-ext-install -j$(nproc) imap \
	&& apt-get purge -y libc-client-dev libkrb5-dev

# APCu
RUN printf "\n" | pecl install apcu \
  && docker-php-ext-enable apcu \
  && pecl install uploadprogress \
  && docker-php-ext-enable uploadprogress \
  && pecl clear-cache

# Sendmail setup
# source: https://r.je/sendmail-php-docker
RUN echo "sendmail_path=/usr/sbin/sendmail -t -i" >> /usr/local/etc/php/conf.d/sendmail.ini \
  && sed -i '/#!\/bin\/sh/aservice sendmail restart' /usr/local/bin/docker-php-entrypoint \
  && sed -i '/#!\/bin\/sh/aecho "$(hostname -i)\t$(hostname) $(hostname).localhost" >> /etc/hosts' /usr/local/bin/docker-php-entrypoint

# Cleanup.
RUN rm -rf /var/lib/apt/lists/*

# Prepare Postges access.
RUN echo 'db:5432:*:postgres:pgBr4P!_D0cker' >~/.pgpass \
  && chmod go-rwx ~/.pgpass

# Set PHP settings.
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
  && perl -pi -e 's/^max_execution_time\s*=.*/max_execution_time = 300/g' "$PHP_INI_DIR/php.ini" \
  && perl -pi -e 's/^max_input_time\s*=.*/max_input_time = 300/g' "$PHP_INI_DIR/php.ini" \
  && perl -pi -e 's/^memory_limit\s*=.*/memory_limit = 512M/g' "$PHP_INI_DIR/php.ini" \
  && perl -pi -e 's/^post_max_size\s*=.*/post_max_size = 256M/g' "$PHP_INI_DIR/php.ini" \
  && perl -pi -e 's/^upload_max_filesize\s*=.*/upload_max_filesize = 256M/g' "$PHP_INI_DIR/php.ini"

# Provide Drupal setting file for external databases.
COPY ./external_dbs.php external_dbs.php

ENV DRUPAL_TRUSTED_HOST="'localhost','127\.0\.0\.1'"

# Init script.
COPY ./init.sh init.sh
RUN chmod u+rx init.sh
CMD ./init.sh
