#!/bin/sh

server_hostname=$1
control_plane_endpoint=$2
service_dns_domain=$3

# Setup hostname
hostnamectl set-hostname $server_hostname

# Install all depdencies and packages
apt-get -y update && apt-get -y upgrade && apt-get -y install git vim tmux ufw apt-transport-https ca-certificates curl gnupg2 software-properties-common etcd-client s3cmd cifs-utils nfs-common open-iscsi jq sudo wireguard wireguard-tools

modprobe iscsi_tcp

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt install containerd.io


wget https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_Linux_amd64.tar.gz
tar -xzvf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/bin/
rm k9s_Linux_amd64.tar.gz LICENSE README.md

ufw allow in 6443
ufw allow in 2379
ufw allow in 2380
ufw allow in 10250
ufw allow in 10259
ufw allow in 10257
ufw allow 179
ufw allow 4789
ufw allow in 5473
ufw allow 51820
ufw allow 51821
ufw allow 17700

sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
modprobe br_netfilter
echo '1' > /proc/sys/net/ipv4/ip_forward
sysctl --system

wget -O /etc/containerd/config.toml https://raw.githubusercontent.com/meezaan/kubernetes/master/etc/containerd/config.toml

wget -O /etc/crictl.yaml https://raw.githubusercontent.com/meezaan/kubernetes/master/etc/crictl.yaml
systemctl restart containerd

wget -O /etc/ssh/sshd_config https://raw.githubusercontent.com/meezaan/kubernetes/master/etc/ssh/sshd_config

service sshd restart

ufw enable

# Start Control Plane
kubeadm init --control-plane-endpoint "$control_plane_endpoint" --node-name "$server_hostname" --service-dns-domain "$service_dns_domain" --pod-network-cidr "192.168.0.0/16" --upload-certs

# Setup kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml
wget https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/custom-resources.yaml -O custom-resources.yaml
kubectl apply -f custom-resources.yaml

# Install calicoctl
wget https://github.com/projectcalico/calico/releases/download/v3.29.1/calicoctl-linux-amd64 -O calicoctl
chmod +x ./calicoctl
sudo mv calicoctl /usr/bin/

sleep 7
calicoctl node status

# Enable encryption for Calico communication between nodes
kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"wireguardEnabled":true}}'
