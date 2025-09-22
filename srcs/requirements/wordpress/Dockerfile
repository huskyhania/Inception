FROM alpine:3.21.3

RUN apk update && apk add mariadb-client \
	php83 \
	php83-fpm \
	php83-phar \
	php83-curl \
	php83-mysqli \
	php83-iconv \
	php83-json \
	php83-mbstring \
	php83-gd \
	php83-xml \
	php83-openssl \
	wget

COPY ./conf/www.conf /etc/php83/php-fpm.d/www.conf

RUN mkdir -p /var/www/wp /var/www/html

RUN if ! getent group www-data; then addgroup -g 82 -S www-data; fi && \
    if ! getent passwd www-data; then adduser -u 82 -D -S -G www-data www-data; fi

RUN mkdir -p /var/lib/nginx/tmp/fastcgi \
    && chown -R www-data:www-data /var/lib/nginx/tmp \
    && chown -R www-data:www-data /var/www


COPY ./tools/wordpress-script.sh /usr/local/bin/wordpress-entrypoint.sh
RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh


EXPOSE 9000

ENTRYPOINT ["wordpress-entrypoint.sh"]
