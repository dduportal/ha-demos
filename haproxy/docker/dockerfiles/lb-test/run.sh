#! /bin/bash

/golang/bin/docker-gen -only-exposed -watch -notify "kill -s HUP $(ps aux | grep nginx | grep master | awk '{print $2}')" /~/nginx.tmpl /etc/nginx/sites-enabled/default 

nginx -c  /etc/nginx/nginx.conf
