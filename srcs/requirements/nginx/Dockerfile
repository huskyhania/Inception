FROM alpine:3.21.3

RUN apk update && apk add nginx openssl

#create a directory for SSL certificate and generate a self-signed cert
RUN mkdir -p /etc/nginx/ssl && \
	openssl req -x509 -nodes \
	-out /etc/nginx/ssl/public_certificate.crt \
	-keyout /etc/nginx/ssl/private.key \
	-subj "/CN=hskrzypi.42.fr"

RUN if ! getent group www-data; then addgroup -g 82 -S www-data; fi && \
    if ! getent passwd www-data; then adduser -u 82 -D -S -G www-data www-data; fi

RUN mkdir -p /var/www/html

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# Make sure directories exist and have correct permissions
RUN mkdir -p /var/lib/nginx && \
    mkdir -p /var/lib/nginx/tmp && \
    mkdir -p /var/lib/nginx/tmp/client_body && \
    mkdir -p /var/lib/nginx/tmp/proxy && \
    mkdir -p /var/lib/nginx/tmp/fastcgi && \
    mkdir -p /var/lib/nginx/tmp/uwsgi && \
    mkdir -p /var/lib/nginx/tmp/scgi

# Set permissions after all directories are created
RUN chown -R www-data:www-data /var/lib/nginx && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/lib/nginx

EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]


