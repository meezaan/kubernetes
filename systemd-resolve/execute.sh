#!/bin/sh

wget -O /tmp/resolved.conf https://raw.githubusercontent.com/meezaan/kubernetes/master/etc/systemd/resolved.conf

apt install systemd-resolved

mv /tmp/resolved.conf /etc/systemd/resolved.conf

systemctl restart systemd-resolved
