#!/bin/bash

sed -i '/nginx/d' /etc/apt/sources.list
echo "deb http://nginx.org/packages/debian/ wheezy nginx" >> /etc/apt/sources.list
echo "deb-src http://nginx.org/packages/debian/ wheezy nginx" >> /etc/apt/sources.list

cd /tmp
sudo wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key
rm -f *key

sudo apt-get update
sudo apt-get install -y nginx vim libnet-ifconfig-wrapper-perl

