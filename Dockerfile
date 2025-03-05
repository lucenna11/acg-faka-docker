# 基于官方 PHP 8.1 镜像构建
FROM php:8.1-apache

# 安装必要工具并动态配置阿里云镜像源，同时解决公钥问题
RUN apt-get update && apt-get install -y lsb-release gnupg && \
    . /etc/os-release && \
    if [ "$ID" = "debian" ]; then \
        # 配置 Debian 阿里云源
        echo "deb http://mirrors.aliyun.com/debian/ $VERSION_CODENAME main contrib non-free" > /etc/apt/sources.list && \
        echo "deb http://mirrors.aliyun.com/debian/ $VERSION_CODENAME-updates main contrib non-free" >> /etc/apt/sources.list && \
        echo "deb http://mirrors.aliyun.com/debian-security/ $VERSION_CODENAME-security main contrib non-free" >> /etc/apt/sources.list && \
        # 导入 Debian 的公钥（从官方源获取）
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138 0E98404D386FA1D9 6ED0E7B82643E131; \
    elif [ "$ID" = "ubuntu" ]; then \
        # 配置 Ubuntu 阿里云源
        echo "deb http://mirrors.aliyun.com/ubuntu/ $VERSION_CODENAME main restricted universe multiverse" > /etc/apt/sources.list && \
        echo "deb http://mirrors.aliyun.com/ubuntu/ $VERSION_CODENAME-security main restricted universe multiverse" >> /etc/apt/sources.list && \
        echo "deb http://mirrors.aliyun.com/ubuntu/ $VERSION_CODENAME-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
        echo "deb http://mirrors.aliyun.com/ubuntu/ $VERSION_CODENAME-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
        # 导入 Ubuntu 的公钥（从官方源获取）
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 871920D1991BC93C; \
    fi && \
    apt-get update

# 安装依赖和 PHP 扩展
RUN apt-get install -y \
    libfreetype-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libssl-dev \
    openssl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql zip sockets \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 复制应用代码
COPY acg-faka /var/www/html

# 配置 Apache
RUN a2enmod rewrite \
    && chown -R www-data:www-data /var/www/html
