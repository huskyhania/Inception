FROM alpine:3.21.3

RUN apk update && apk add nginx openssl

#create a directory for SSL certificate and generate a self-signed cert
RUN mkdir -p /etc/nginx/ssl && \
	openssl req -x509 -nodes \
	-out /etc/nginx/ssl/public_certificate.crt \
	-keyout /etc/nginx/ssl/private.key \
	-subj "/CN=hskrzypi.42.fr"

RUN adduser -D -H -s /sbin/nologin -g www-data -G www-data www-data

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

RUN chmod 644 /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]


