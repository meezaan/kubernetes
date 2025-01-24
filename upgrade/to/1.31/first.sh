#!/bin/sh

wget -O /etc/apt/sources.list.d/kubernetes.list https://raw.githubusercontent.com/meezaan/kubernetes/refs/heads/master/sources/1.31
apt update && apt -y upgrade
apt-cache madison kubeadm

apt-mark unhold kubeadm && \
apt-get update && sudo apt-get install -y kubeadm='1.31.*' && \
apt-mark hold kubeadm

kubeadm version

kubeadm upgrade plan

# On first node run
kubeadm --v=8 upgrade apply v1.31.5

## KUBELET

apt-mark unhold kubelet kubectl && \
apt-get update && sudo apt-get install -y kubelet='1.31.*' kubectl='1.31.*' && \
apt-mark hold kubelet kubectl

systemctl daemon-reload
systemctl restart kubelet