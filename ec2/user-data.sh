#!/bin/bash

# timezone
rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# hostname
hostnamectl set-hostname ${hostname}

# kubelet, kubeadm, kubectl
sudo apt update
sudo apt -y install curl apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt -y install vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# load kernel module
sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

# install docker
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl daemon-reload 
sudo systemctl restart docker
sudo systemctl enable docker

# local_ip, hostname env
local_ip=`hostname -I | awk '{print $1}'`
public_ip=`curl ifconfig.me`
hostname=${hostname}
echo -e "$local_ip $hostname.k8s" | sudo tee -a /etc/hosts

# master / master
if [ "master" == ${hostname} ]; then
  # kubelet service
  systemctl enable kubelet
  kubeadm config images pull
  
  # create cluster
  sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-cert-extra-sans=${external_ip} --control-plane-endpoint=$public_ip:6443
  
  sleep 10
  mkdir -p /home/ubuntu/.kube
  sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
  sudo chown -R ubuntu. /home/ubuntu/.kube
  
  
  export KUBECONFIG=/etc/kubernetes/admin.conf
  
  while [[ ! $(sudo file -f /etc/kubernetes/admin.conf) ]];
    do
      sleep 2
    done
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  
else
  true
fi