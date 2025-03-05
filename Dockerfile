# 使用阿里云镜像加速：基于 Debian 的 PHP 8.1 Apache 官方镜像
FROM php:8.1-apache

# 替换阿里云镜像源 & 安装依赖项
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        libfreetype-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        libssl-dev \
        openssl \
        tzdata \
        curl \
    # 配置 PHP 扩展
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql zip sockets \
    # 配置时区（上海）
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    # 安全加固：禁用危险函数
    && echo "disable_functions = exec,passthru,shell_exec,system,proc_open,popen" >> /usr/local/etc/php/conf.d/security.ini \
    # Apache 日志重定向到标准输出
    && ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stderr /var/log/apache2/error.log \
    # 清理缓存减小镜像体积
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 强制使用 www-data 用户运行（官方镜像默认已处理）
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data

# 应用代码复制（注意排除敏感文件）
COPY acg-faka /var/www/html

# 设置文件权限（避免使用 chmod -R 777）
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \; \
    # 删除项目中的敏感文件（根据实际情况调整）
    && rm -rf /var/www/html/.git /var/www/html/composer.lock

# 启用 Apache Rewrite 模块
RUN a2enmod rewrite

# 健康检查（每5分钟检测一次，超时3秒）
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

# 暴露端口
EXPOSE 80

# 保持官方默认启动命令
CMD ["apache2-foreground"]
