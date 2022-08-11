FROM alpine:3.16

ARG PHP

# ensure www-data user exists
RUN set -eux; \
	adduser -u 82 -D -S -G www-data www-data
# 82 is the standard uid/gid for "www-data" in Alpine

ENV PHP_SUFFIX="$PHP"

# Configs
ENV BUILD_CONFIG_PHP="/etc/php$PHP_SUFFIX/conf.d/99_settings.ini"
ENV BUILD_CONFIG_NGINX="/etc/nginx/nginx.conf"
ENV BUILD_CONFIG_PHP_FPM="/etc/php$PHP_SUFFIX/php-fpm.d/www.conf"
ENV BUILD_CONFIG_SUPERVISOR="/etc/supervisor/conf.d/supervisord.conf"

## From https://github.com/docker-library/php/blob/master/8.1/alpine3.15/fpm/Dockerfile
ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev dpkg \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkgconf \
		re2c

# Iconv fix
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.12/community/ --allow-untrusted gnu-libiconv=1.15-r2
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

RUN apk --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/main add \
    icu-libs \
    && apk --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/main add \
    # Current packages don't exist in other repositories
    libavif \
    && apk add --no-cache --allow-untrusted gnu-libiconv \
    # Packages \
    curl \
    php$PHP_SUFFIX \
    php$PHP_SUFFIX-dev \
    php$PHP_SUFFIX-common \
    php$PHP_SUFFIX-gd \
    php$PHP_SUFFIX-xmlreader \
    php$PHP_SUFFIX-xmlwriter \
    php$PHP_SUFFIX-fileinfo \
    php$PHP_SUFFIX-bcmath \
    php$PHP_SUFFIX-ctype \
    php$PHP_SUFFIX-curl \
    php$PHP_SUFFIX-exif \
    php$PHP_SUFFIX-iconv \
    php$PHP_SUFFIX-intl \
    php$PHP_SUFFIX-mbstring \
    php$PHP_SUFFIX-opcache \
    php$PHP_SUFFIX-openssl \
    php$PHP_SUFFIX-pcntl \
    php$PHP_SUFFIX-phar \
    php$PHP_SUFFIX-session \
    php$PHP_SUFFIX-xml \
    php$PHP_SUFFIX-xsl \
    php$PHP_SUFFIX-zip \
    php$PHP_SUFFIX-zlib \
    php$PHP_SUFFIX-dom \
    php$PHP_SUFFIX-fpm \
    php$PHP_SUFFIX-sodium \
    php$PHP_SUFFIX-pecl-imagick \
    php$PHP_SUFFIX-pecl-redis \
    php$PHP_SUFFIX-simplexml \
    php$PHP_SUFFIX-sockets \
    php$PHP_SUFFIX-pdo \
    php$PHP_SUFFIX-pdo_mysql \
    php$PHP_SUFFIX-tokenizer \
    php$PHP_SUFFIX-soap \
    php$PHP_SUFFIX-pecl-apcu # Iconv Fix

# Nginx + supervisor

RUN apk add --no-cache \
    supervisor \
    nginx \
    nginx-mod-http-brotli \
    # Tools
    vim

# Symlink php81 => php
RUN ln -s /usr/bin/php$PHP_SUFFIX /usr/bin/php
RUN ln -s /usr/sbin/php-fpm$PHP_SUFFIX /usr/bin/php-fpm
RUN ln -s /usr/bin/phpize$PHP_SUFFIX /usr/bin/phpize
RUN ln -s /usr/bin/php-config$PHP_SUFFIX /usr/bin/php-config

# Symlink nginx
RUN ln -s /usr/sbin/nginx /usr/bin/nginx

## Composer
RUN curl -sfL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
        chmod +x /usr/bin/composer

# Configs php
COPY conf/php/php.ini "$BUILD_CONFIG_PHP"

# Configs php-fpm
COPY conf/php-fpm/php-fpm.conf "/etc/php$PHP_SUFFIX/php-fpm.conf"
RUN sed -i -e "s/;include=/include = \/etc\/php$PHP_SUFFIX\/php-fpm.d\/*.conf/g" "/etc/php$PHP_SUFFIX/php-fpm.conf"

COPY conf/php-fpm/www.conf "$BUILD_CONFIG_PHP_FPM"

# Configs nginx
COPY conf/nginx/includes/ /etc/nginx/includes/
COPY conf/nginx/nginx.conf "$BUILD_CONFIG_NGINX"

# Configs supervisor
COPY conf/supervisor/supervisord.conf "$BUILD_CONFIG_SUPERVISOR"

RUN mkdir -p /app/www /home/www-data/log /home/www-data/tmp && mkdir /.composer

RUN chown -R www-data.www-data /app && \
    chown -R www-data.www-data /run && \
    chown -R www-data.www-data /var/log && \
    chown -R www-data.www-data /.composer

## Nginx permissions

RUN chown -R www-data.www-data /var/lib/nginx
RUN chown -R www-data.www-data /var/log/nginx
RUN chown -R www-data.www-data /home/www-data

RUN chmod -R 777 /var/lib/nginx
RUN chmod -R 777 /var/log
RUN chmod -R 777 /home/www-data
RUN chmod -R 777 /run
RUN chmod -R 777 /app

WORKDIR /app

# Switch to use a non-root user from here on
USER www-data

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
