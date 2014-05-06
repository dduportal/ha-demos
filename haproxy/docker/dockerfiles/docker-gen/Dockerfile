FROM debian:jessie
MAINTAINER damien.duportal@gmail.com

ENV DOCKERGEN_VERSION 0.1.2

RUN apt-get update && apt-get install -y wget

ADD test.tmpl /app/

WORKDIR /usr/local/bin
RUN wget https://github.com/jwilder/docker-gen/releases/download/${DOCKERGEN_VERSION}/docker-gen-linux-amd64-${DOCKERGEN_VERSION}.tar.gz -O dockergen.tgz
RUN tar xzf dockergen.tgz && rm -f dockergen.tgz

WORKDIR /app

