#!/bin/bash

# Adding EPEL
rpm -ivh http://mirrors.ircam.fr/pub/fedora/epel/6/i386/epel-release-6-8.noarch.rpm

# Adding reverbrain repo

cat > /etc/yum.repos.d/reverbrain.repo <<EOF
[reverbrain]
name=Reverbrain Repo for EL $releasever - Current
baseurl=http://repo.reverbrain.com/rhel/current/\$releasever/\$basearch/
enabled=1
gpgcheck=1
gpgkey=http://repo.reverbrain.com/REVERBRAIN.GPG
EOF

yum install -y nano wget vim curl git telnet libev libev elliptics

mkdir -p /app/conf /app/data /app/history
chmod -R 750 /app
chown -R vagrant:vagrant /app

VM_ADDR=$(ifconfig | grep 192.168 | awk '{print $2}' | cut -d':' -f2)

cat > /app/conf/ioserv.json <<EOF
{
	"loggers": {
		"type": "/dev/stderr",
		"level": 4,
		"root": [
			{
				"formatter": {
					"type": "string",
					"pattern": "[%(timestamp)s]: %(message)s [%(...L)s]"
				},
				"sink": {
					"type": "files",
					"path": "/dev/stdout",
					"autoflush": true
				}
			}
		]
	},
	"options": {
		"join": true,
		"flags": 20,
		"address": [
			"${VM_ADDR}:1025:2-0"
		],
		"wait_timeout": 60,
		"check_timeout": 60,
		"io_thread_num": 16,
		"nonblocking_io_thread_num": 16,
		"net_thread_num": 4,
		"daemon": true,
		"auth_cookie": "qwerty",
		"bg_ionice_class": 3,
		"bg_ionice_prio": 0,
		"server_net_prio": 1,
		"client_net_prio": 6,
		"cache": {
			"size": 68719476736
		},
		"indexes_shard_count": 2,
		"monitor_port": 20000
	},
	"backends": [
		{
			"type": "blob",
			"group": 2,
			"history": "/app/history",
			"data": "/app/data",
			"sync": "-1",
			"blob_flags": "158",
			"blob_size": "10G",
			"records_in_blob": "1000000"
		}
	]
}
EOF

# Launch server
dnet_ioserv -c /app/conf/ioserv.json

