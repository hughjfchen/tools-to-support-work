#!/usr/bin/env sh
docker stop $(docker ps | grep -w wg-for-phone | awk '{print $1}')
docker stop $(docker ps | grep -w wg-for-laptop| awk '{print $1}')
docker run -dt --rm --name wg-for-phone --cap-add net_admin --cap-add sys_module -v /root/wg0:/etc/wireguard -p 5555:5555/udp cmulk/wireguard-docker:stretch
docker run -dt --rm --name wg-for-laptop --cap-add net_admin --cap-add sys_module -v /root/wg1:/etc/wireguard -p 6666:6666/udp cmulk/wireguard-docker:stretch
docker stop $(docker ps | grep -w ssserver-kcptun| awk '{print $1}')
docker stop $(docker ps | grep -w ssserver-obfs| awk '{print $1}')
docker run -dt --rm --name ssserver-kcptun -p 6443:6443 -p 6500:6500/udp mritd/shadowsocks -m "ss-server" -s "-s 0.0.0.0 -p 6443 -m chacha20-ietf -k Passw0rd" -x -e "kcpserver" -k "-t 127.0.0.1:6443 -l :6500 -mode fast2"
docker run -dt --rm --name ssserver-obfs -p 8443:8443 mritd/shadowsocks -m "ss-server" -s "-s 0.0.0.0 -p 8443 -m chacha20-ietf -k Passw0rd --plugin obfs --plugin-opts obfs=tls"
