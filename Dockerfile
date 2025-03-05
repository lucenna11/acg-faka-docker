FROM php:8.1-apache

# 安装必要工具并动态配置阿里云镜像源，解决公钥问题
RUN apt-get update && apt-get install -y lsb-release gnupg && \
    # 加载系统信息
    . /etc/os-release && \
    echo "Detected OS: $ID $VERSION_CODENAME" && \
    # 清空所有默认源
    > /etc/apt/sources.list && \
    rm -rf /etc/apt/sources.list.d/* && \
    # 根据发行版配置阿里云源
    if [ "$ID" = "debian" ]; then \
        echo "deb http://mirrors.aliyun.com/debian/ $VERSION_CODENAME main contrib non-free" > /etc/apt/sources.list && \
        echo "deb http://mirrors.aliyun.com/debian/ $VERSION_CODENAME-updates main contrib non-free" >> /etc/apt/sources.list && \
        echo "deb http://mirrors.aliyun.com/debian-security/ $VERSION_CODENAME-security main contrib non-free" >> /etc/apt/sources.list && \
        echo "New sources.list content:" && cat /etc/apt/sources.list && \
        # 导入 Debian 公钥
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138 0E98404D386FA1D9 6ED0E7B82643E131; \
    elif [ "$ID" = "ubuntu" ]; then \
        echo "deb http://mirrors.aliyun.com/ubuntu/ $VERSION_CODENAME main restricted universe multiverse" > /etc/apt/sources.list && \
        echo "deb http://mirrors.aliyun.com/ubuntu/ $VERSION_CODENAME-security main restricted universe multiverse" >> /etc/apt/sources.list && \
        echo "deb http://mirrors.aliyun.com/ubuntu/ $VERSION_CODENAME-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
        echo "deb http://mirrors.aliyun.com/ubuntu/ $VERSION_CODENAME-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
        echo "New sources.list content:" && cat /etc/apt/sources.list && \
        # 导入 Ubuntu 公钥
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 871920D1991BC93C; \
    fi && \
    # 确认源配置后再次更新
    apt-get update && \
    echo "APT update completed, checking sources used..."

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
