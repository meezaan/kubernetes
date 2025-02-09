#!/bin/sh

apt update
unlink /etc/resolv.conf

echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

apt install -y dnsmasq
systemctl is-enabled dnsmasq
 cp /etc/dnsmasq.conf{,.orig}
