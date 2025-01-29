#!/bin/sh

apt install systemd-resolved

wget -O /etc/systemd/resolved.conf https://raw.githubusercontent.com/meezaan/kubernetes/master/etc/systemd/resolved.conf

systemctl restart systemd-resolved
