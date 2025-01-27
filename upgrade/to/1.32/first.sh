#!/bin/sh

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
wget -O /etc/apt/sources.list.d/kubernetes.list https://raw.githubusercontent.com/meezaan/kubernetes/refs/heads/master/sources/1.32
apt update && apt -y upgrade
apt-cache madison kubeadm

apt-mark unhold kubeadm && \
apt-get update && sudo apt-get install -y kubeadm='1.32.*' && \
apt-mark hold kubeadm

kubeadm version

kubeadm upgrade plan

# On first node run
kubeadm --v=8 upgrade apply v1.32.1

## KUBELET

apt-mark unhold kubelet kubectl && \
apt-get update && sudo apt-get install -y kubelet='1.32.*' kubectl='1.32.*' && \
apt-mark hold kubelet kubectl

systemctl daemon-reload
systemctl restart kubelet

# Upgrade Calico
curl https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml -O
kubectl apply --server-side --force-conflicts -f tigera-operator.yaml
wget https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml -O custom-resources.yaml
kubectl apply -f custom-resources.yaml

# Upgrade calicoctl
wget https://github.com/projectcalico/calico/releases/download/v3.29.1/calicoctl-linux-amd64 -O calicoctl
chmod +x ./calicoctl
sudo mv calicoctl /usr/bin/
calicoctl node status