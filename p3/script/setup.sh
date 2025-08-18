#!/bin/bash

# Créer un cluster K3D
k3d cluster create argo-cluster --port 8080:80@loadbalancer -p 8888:80@loadbalancer
sleep 10
kubectl cluster-info

# Créer les namespaces
kubectl create namespace argocd
kubectl create namespace dev

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Attendre que les pods Argo CD soient prêts
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Créer une application Argo CD pour déployer dans le namespace dev
kubectl apply -f /usr/local/bin/argocd-app.yaml

# Afficher l'état des pods Argo CD
kubectl get pods -n argocd

echo "Cluster configuré avec succès !"
echo "Namespaces créés : argocd, dev"
echo "Pour accéder à Argo CD UI: kubectl port-forward svc/argocd-server -n argocd 8080:80"