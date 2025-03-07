# 基于官方 PHP 8.1 镜像构建
FROM php:8.1-apache

RUN apt-get update && apt-get install -y \
    libfreetype-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libssl-dev \
    openssl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql zip sockets

ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

RUN { \
 echo 'ServerName ip.gdbridg.com'; \
    echo '<Directory /var/www/html>'; \
    echo '  Options -Indexes +FollowSymLinks'; \
    echo '  AllowOverride All'; \
    echo '  Require all granted'; \
    echo '  DirectoryIndex index.php index.html'; \
    echo '</Directory>'; \
} >> /etc/apache2/apache2.conf


RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*
    
COPY ./acg-faka /var/www/html

RUN { \
    echo 'display_errors = On'; \
    echo 'display_startup_errors = On'; \
    echo 'error_reporting = E_ALL'; \
} > /usr/local/etc/php/conf.d/overrides.ini


# 保持官方默认启动命令
RUN a2enmod rewrite
RUN chown -R www-data:www-data /var/www/html


