#!/bin/bash

# Installing stuff
echo "== Checkin' and installin' some needed stuff"
sed -i '/nginx/d' /etc/apt/sources.list
echo "deb http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list
echo "deb-src http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list

cd /tmp
sudo wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key
rm -f *key

sudo apt-get update
sudo apt-get install -y nginx vim libnet-ifconfig-wrapper-perl

echo "== Adding nginx content"
cat > /usr/share/nginx/html/check.txt << EOF
OK
EOF

MY_SERVICE_IP=$(/sbin/ifconfig | grep eth1 -A2 | grep 'inet addr' | awk '{print $2}' | cut -d':' -f2)

cat > /usr/share/nginx/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>
My IP is $MY_SERVICE_IP
</p>
</body>
</html>
EOF
