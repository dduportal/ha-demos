#!/bin/bash

### Adding backports repository
echo "== Cheking and installing all missing stuff"
sed -i '/backports/d' /etc/apt/sources.list
echo "deb http://ftp.debian.org/debian/ wheezy-backports main" >> /etc/apt/sources.list
apt-get update

### Install all needed tools
apt-get install -y keepalived vim curl libnet-ifconfig-wrapper-perl haproxy vim-haproxy

### Configure keepalive
echo "== Configuring Keepalive"
update-rc.d keepalived defaults
if [[ $(/sbin/ifconfig | grep 'inet addr' | grep 192.168.0.11 | wc -l) -ne 0 ]]; then
	KEEPALIVE_PRIORITY=101 # We are master
else
	KEEPALIVE_PRIORITY=100 # We are backup
fi
cat > /etc/keepalived/keepalived.conf << EOF

vrrp_script chk_haproxy {
	script "killall -0 haproxy"     # cheaper than pidof
	interval 2
	weight 2
}

vrrp_instance VI_1 {
	interface eth1
	state MASTER
        virtual_router_id 51
	priority ${KEEPALIVE_PRIORITY} # 101 on master, 100 on backup
	virtual_ipaddress {
		192.168.0.10
        }
        track_script {
            chk_haproxy
        }
}
EOF


### Configure HAProxy
echo "== Configurint HA Proxy"
sed -i 's/ENABLED=./ENABLED=1/g' /etc/default/haproxy 
cat > /etc/haproxy/haproxy.cfg << EOF
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        user haproxy
        group haproxy
        daemon

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        contimeout 5000
        clitimeout 50000
        srvtimeout 50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

listen webfarm *:80
       mode http
       stats enable
       stats auth user:pass
       balance roundrobin
       cookie SERVERID insert
       option http-server-close
       option forwardfor
       option httpchk HEAD /check.txt HTTP/1.0
       server webA 192.168.0.21:80 cookie A check
       server webB 192.168.0.22:80 cookie B check
EOF


### Configuring and loading kernel parameters
echo "== Configuring Kernel"
sed -i '/ipv4.ip_forward/d' /etc/sysctl.conf
sed -i '/ipv4.ip_nonlocal_bind/d' /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv4.ip_nonlocal_bind = 1" >> /etc/sysctl.conf
sysctl -p

### GO !
echo "== Startin' services"
service haproxy start
service keepalived start

