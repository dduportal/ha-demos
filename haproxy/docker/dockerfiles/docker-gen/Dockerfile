FROM juju-nginx

RUN apt-get install -y golang git

WORKDIR /golang
ENV GOPATH /golang

RUN go get github.com/jwilder/docker-gen

CMD ["/golang/bin/docker-gen","-v"]
