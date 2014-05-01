FROM debian:jessie
MAINTAINER damien.duportal@gmail.com

RUN apt-get update && apt-get install -y \
	vim \
	procps \
	libnet-ifconfig-wrapper-perl 
RUN apt-get install -y nodejs

ADD index.js /webapp/

EXPOSE 8080

CMD ["nodejs", "/webapp/index.js"]

