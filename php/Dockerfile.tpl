FROM php:{{ .php_version }}-fpm-alpine AS base

# Install main required packages
RUN apk add zlib libpng openldap imagemagick imagemagick-pdf libgomp yaml icu-libs freetype libjpeg-turbo libwebp

# Install sqlsrv deps
RUN apk add --no-cache curl unixodbc unixodbc-dev ca-certificates && update-ca-certificates
RUN cd /tmp && \
    curl -O {{ .msodbcsql_package_base_url }}/msodbcsql{{ .msodbc_version }}_{{ .msodbcsql_package_version }}_amd64.apk && \
    curl -O {{ .mssql_tools_package_base_url }}/mssql-tools{{ .msodbc_version }}_{{ .mssql_tools_package_version }}_amd64.apk && \
    apk add --allow-untrusted msodbcsql{{ .msodbc_version }}_{{ .msodbcsql_package_version }}_amd64.apk && \
    apk add --allow-untrusted mssql-tools{{ .msodbc_version }}_{{ .mssql_tools_package_version }}_amd64.apk

# Install non-core extensions
RUN --mount=type=bind,from=ghcr.io/php/pie:bin,source=/pie,target=/usr/local/bin/pie \
    apk add --no-cache --virtual .icu-build-deps $PHPIZE_DEPS zlib-dev libpng-dev imagemagick-dev oniguruma-dev ghostscript-dev && \
    pie install imagick/imagick && \
    docker-php-ext-enable imagick && \
    apk del --no-network .icu-build-deps
RUN --mount=type=bind,from=ghcr.io/php/pie:bin,source=/pie,target=/usr/local/bin/pie \
    apk add --no-cache --virtual .icu-build-deps $PHPIZE_DEPS yaml-dev && \
    pie install pecl/yaml && \
    docker-php-ext-enable yaml && \
    apk del --no-network .icu-build-deps
RUN --mount=type=bind,from=ghcr.io/php/pie:bin,source=/pie,target=/usr/local/bin/pie \
    apk add --no-cache --virtual .icu-build-deps $PHPIZE_DEPS && \
    pie install apcu/apcu && \
    docker-php-ext-enable apcu && \
    apk del --no-network .icu-build-deps
RUN --mount=type=bind,from=ghcr.io/php/pie:bin,source=/pie,target=/usr/local/bin/pie \
    apk add --no-cache --virtual .icu-build-deps $PHPIZE_DEPS && \
    pie install microsoft/pdo_sqlsrv && \
    pie install microsoft/sqlsrv && \
    docker-php-ext-enable pdo_sqlsrv sqlsrv && \
    apk del --no-network .icu-build-deps

# Install core extensions
RUN apk add --no-cache --virtual .icu-build-deps freetype-dev libpng-dev libjpeg-turbo-dev libwebp-dev && \
    docker-php-ext-configure gd --with-freetype --with-webp --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd && \
    apk del --no-network .icu-build-deps
RUN apk add --no-cache openldap-dev && \
    docker-php-ext-configure ldap && \
    docker-php-ext-install -j$(nproc) ldap && \
    apk del --no-cache openldap-dev
RUN apk add --no-cache icu-dev && \
    docker-php-ext-configure intl && \
    docker-php-ext-install -j$(nproc) intl && \
    apk del --no-cache icu-dev
{{if ne .php_version "8.5" }}
RUN docker-php-ext-configure opcache && \
    docker-php-ext-install -j$(nproc) opcache
{{end}}

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
