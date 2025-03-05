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


COPY acg-faka /var/www/html
RUN chown -R www-data:www-data /var/www/html

# 暴露端口
EXPOSE 80

# 保持官方默认启动命令
CMD ["apache2-foreground"]
