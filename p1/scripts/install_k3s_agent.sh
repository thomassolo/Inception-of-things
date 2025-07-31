#!/bin/bash

echo "=== Installation K3s Agent ==="

# Mise à jour du système
sudo apt-get update -y

# Attendre que le token soit disponible depuis le serveur
echo "Attente du token du serveur..."
while [ ! -f /vagrant/node-token ]; do
    echo "Token non trouvé, attente..."
    sleep 5
done

# Lire le token
TOKEN=$(cat /vagrant/node-token)
echo "Token récupéré"

# Installation de K3s en mode agent
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$TOKEN sh -

# Attendre que l'agent soit prêt
echo "Attente du démarrage de K3s agent..."
sleep 20

# Vérifier que K3s agent fonctionne
sudo systemctl status k3s-agent --no-pager

echo "K3s agent installé avec succès sur $(hostname)"