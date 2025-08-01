#!/bin/bash

echo "=== Installation K3s Agent ==="

# Mise à jour du système
sudo apt-get update -y

# Attendre que le token soit disponible
echo "Attente du token du serveur..."
while [ ! -f /vagrant/node-token ]; do
    echo "Token non trouvé, attente..."
    sleep 10
done

# Récupérer le token
TOKEN=$(cat /vagrant/node-token)
echo "Token récupéré : $TOKEN..."

# Installation de K3s en mode agent
curl -sfL https://get.k3s.io/ | K3S_URL=https://192.168.56.110:6443/ K3S_TOKEN=$TOKEN sh -

# Attendre que l'agent soit prêt
echo "Attente du démarrage de K3s agent..."
sleep 30

# Vérifier le statut
sudo systemctl status k3s --no-pager

echo "K3s agent installé avec succès sur $(hostname)"