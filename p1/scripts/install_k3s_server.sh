#!/bin/bash

# Mise à jour du système
sudo apt-get update

# Installation de K3s en mode server
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

# Attendre que K3s soit prêt
sleep 30

# Récupérer le token pour les agents
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token

# Installer kubectl (déjà inclus avec K3s, mais s'assurer du PATH)
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc

# Copier la config kubectl pour l'utilisateur vagrant
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config 2>/dev/null || true
sudo mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config

echo "K3s server installé avec succès"