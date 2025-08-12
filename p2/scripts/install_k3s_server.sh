#!/bin/bash

# Mise à jour du système
sudo apt-get update -y
sudo apt install net-tools

# Installation de K3s en mode server (simple)
curl -sfL https://get.k3s.io/ | sh -s - --write-kubeconfig-mode 644

# Attendre que K3s soit prêt
echo "Attente du démarrage du serveur K3s..."
  until kubectl get nodes | grep -q Ready; do
    echo "Waiting for K3s to be ready..."
    sleep 2
  done

# Vérifier que le service fonctionne
sudo systemctl status k3s --no-pager

# Récupérer le token pour les agents
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token

# Configuration kubectl pour vagrant
sudo mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config

echo "K3s server installé avec succès"
echo "Token sauvé dans /vagrant/node-token"