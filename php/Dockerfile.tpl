FROM php:{{ .php_version }}-fpm-alpine as base
# Install packages
RUN apk add zlib zlib-dev libpng libpng-dev openldap openldap-dev imagemagick imagemagick-dev oniguruma-dev autoconf libgomp yaml yaml-dev icu-dev

# Install phpize extension build deps
RUN apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS

# Install sqlsrv deps
RUN apk add --no-cache curl unixodbc unixodbc-dev ca-certificates && update-ca-certificates
RUN cd /tmp && \
    curl -O {{ .ms_alpine_base_url }}/msodbcsql{{ .msodbc_version }}_{{ .msodbcsql_package_version }}_amd64.apk && \
    curl -O {{ .ms_alpine_base_url }}/mssql-tools{{ .msodbc_version }}_{{ .mssql_tools_package_version }}_amd64.apk && \
    apk add --allow-untrusted msodbcsql{{ .msodbc_version }}_{{ .msodbcsql_package_version }}_amd64.apk && \
    apk add --allow-untrusted mssql-tools{{ .msodbc_version }}_{{ .mssql_tools_package_version }}_amd64.apk

# Install PECL extensions: we do these first as docker-php-ext-install will clean up the phpize deps
RUN pecl install imagick && docker-php-ext-enable imagick
RUN pecl install redis-5.3.7 && docker-php-ext-enable redis
RUN pecl install yaml && docker-php-ext-enable yaml
RUN pecl install pdo_sqlsrv && \
    pecl install sqlsrv && \
    docker-php-ext-enable pdo_sqlsrv sqlsrv

# Install core extensions
RUN docker-php-ext-configure gd && \
    docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-configure ldap && \
    docker-php-ext-install -j$(nproc) ldap
RUN docker-php-ext-configure intl && \
    docker-php-ext-install -j$(nproc) intl

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
