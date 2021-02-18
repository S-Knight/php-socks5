FROM composer:1.10.20 as composer

COPY composer.json  /app/

RUN set -x ; cd /app \
      && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
      && composer install

FROM php:7.4.15-cli as socks5-proxy

ENV PROXY_PORT 1080

ARG PROXY_PATH=/app/socks5_proxy

WORKDIR ${PROXY_PATH}

COPY --from=composer /app/vendor ${PROXY_PATH}/vendor/
COPY . ${PROXY_PATH}

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions pcntl

EXPOSE $PROXY_PORT

ENTRYPOINT php start.php start
