#!/bin/bash

echo "deb http://ftp.debian.org/debian/ wheezy-backports main" >> /etc/apt/sources.list

apt-get update
apt-get install -y keepalived vim curl libnet-ifconfig-wrapper-perl haproxy vim-haproxy

update-rc.d keepalived defaults

echo "net.ipv4.ip_nonlocal_bind = 1" >> /etc/sysctl.conf
sysctl -p
