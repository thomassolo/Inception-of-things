#!/bin/bash

# Update system
apt-get update -y

# Install curl if not present
apt-get install -y curl

# Install K3s in server mode
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --node-ip 192.168.56.110 --bind-address 192.168.56.110" sh -

# Wait for K3s to be ready
echo "Waiting for K3s to be ready..."
sleep 30

# Check K3s status
systemctl status k3s --no-pager

# Set up kubectl for vagrant user
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
chmod 600 /home/vagrant/.kube/config

# Set up KUBECONFIG for vagrant user
echo 'export KUBECONFIG=/home/vagrant/.kube/config' >> /home/vagrant/.bashrc

# Create alias for kubectl
echo 'alias k=kubectl' >> /home/vagrant/.bashrc

echo "K3s installation completed!"
echo "Use 'kubectl get nodes' to verify the installation"