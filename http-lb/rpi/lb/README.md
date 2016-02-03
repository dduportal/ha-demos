# Raspberry Pi load balancer configuration

* First, install those packages :
  * haproxy : a layer 4 loadbalancer, run in userland
  * keepalivd : a routing software used to achieve high availability

* Then configure haproxy load balancer on each node :
  * In ```/etc/default/haproxy```, please check that "ENABLED" has the value "1"
  * Create/edit the main configuration in ```/etc/haproxy/haproxy.cfg``` (adapting values of <IPA> and <IPB> and their ports) :
    ```
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
        server webA <IPA>:80 cookie A check
        server webB <IPB>:80 cookie B check*
    ```
  * Then enable and start the service :
   ```
   systemctl enable haproxy
   systemctl start haproxy
   ```
* Then configure keepalived on each node :
 * Edit/create the file ```/etc/keepalived/keepalived.conf``` (tune values "<VRID>", "<KEEPALIVE_PRIORITY>", "<VIRTUAL_IP>") :
   ```
   vrrp_script chk_haproxy {
        script "killall -0 haproxy"     # cheaper than pidof
        interval 2
        weight 2
   }
   
   vrrp_instance VI_1 {
        interface eth1
        state MASTER
        virtual_router_id <VRID>
        priority <KEEPALIVE_PRIORITY> # 100 on master, 101 on slave
        virtual_ipaddress {
                <VIRTUAL_IP>
        }
        track_script {
        chk_haproxy
        }
   }
   ```
  * Then enable and start the service :
   ```
   systemctl enable keepalived
   systemctl start keepalived
   ```
* Finally, you yhave to tune the kernel :
 * In ``/etc/sysctl.conf```, ensure that "net.ipv4.ip_forward" and "net.ipv4.ip_nonlocal_bind" are set to 1
 * Reboot !
