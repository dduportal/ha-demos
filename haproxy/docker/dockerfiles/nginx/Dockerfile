FROM debian:jessie
MAINTAINER <Julien Levesy jlevesy@gmail.com>

RUN apt-get update && apt-get install -y \
        vim \
	curl \
        procps \
        libnet-ifconfig-wrapper-perl

RUN apt-get install -y nginx-full

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

EXPOSE 80

VOLUME /var/log/nginx
VOLUME /etc/nginx

CMD ["nginx","-c","/etc/nginx/nginx.conf"]
