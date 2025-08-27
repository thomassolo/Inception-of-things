#!/bin/bash

echo "Setting up K3d cluster for IoT Part 3..."

# Créer un cluster K3D avec des ports libres
k3d cluster create iot-cluster \
  --port "9080:80@loadbalancer" \
  --port "9443:443@loadbalancer" \
  --port "9888:8888@loadbalancer" \
  --agents 1

# Attendre que le cluster soit prêt
echo "Waiting for cluster to be ready..."
sleep 30

# Vérifier le cluster
kubectl cluster-info
kubectl get nodes

# Créer les namespaces
echo "Creating namespaces..."
kubectl create namespace argocd
kubectl create namespace dev

# Installer Argo CD
echo "Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Attendre que les pods Argo CD soient prêts
echo "Waiting for Argo CD to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

# Récupérer le mot de passe admin initial
echo "Getting Argo CD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Configurer le port-forward pour Argo CD UI (HTTPS sur port 443)
echo "Setting up port forwarding for Argo CD UI..."
nohup kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0 > /tmp/argocd-port-forward.log 2>&1 &

# Attendre un peu pour que le port-forward soit actif
sleep 5

# Déployer l'application via Argo CD
echo "Deploying application via Argo CD..."
kubectl apply -f /home/tsoloher/Inception-of-things/p3/scripts/argocd-app.yaml

echo ""
echo "=== SETUP COMPLETED ==="
echo "Argo CD UI: https://localhost:8080 (accept self-signed cert)"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo ""
echo "Application will be deployed in 'dev' namespace"
echo "Access app: http://localhost:8888"
echo ""
echo "=== CURRENT STATUS ==="
kubectl get pods -n argocd
kubectl get pods -n dev