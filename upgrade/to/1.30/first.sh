#!/bin/sh

wget -O /etc/apt/sources.list.d/kubernetes.list https://raw.githubusercontent.com/meezaan/kubernetes/refs/heads/master/sources/1.30
apt update && apt -y upgrade
apt-cache madison kubeadm

apt-mark unhold kubeadm && \
apt-get update && sudo apt-get install -y kubeadm='1.30.*' && \
apt-mark hold kubeadm

kubeadm version

kubeadm upgrade plan

# On first node run
kubeadm --v=8 upgrade apply v1.30.5

## KUBELET

apt-mark unhold kubelet kubectl && \
apt-get update && sudo apt-get install -y kubelet='1.30.*' kubectl='1.30.*' && \
apt-mark hold kubelet kubectl

systemctl daemon-reload
systemctl restart kubelet

# Upgrade Calico
curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml -O
kubectl apply --server-side --force-conflicts -f tigera-operator.yaml
wget https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/custom-resources.yaml -O custom-resources.yaml
kubectl apply -f custom-resources.yaml

# Upgrade calicoctl
wget https://github.com/projectcalico/calico/releases/download/v3.28.2/calicoctl-linux-amd64 -O calicoctl
chmod +x ./calicoctl
sudo mv calicoctl /usr/bin/
calicoctl node status