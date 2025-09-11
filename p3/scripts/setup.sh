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

# Wait for Argo CD to be ready with proper timeout and retries
echo "Waiting for Argo CD to be ready..."
for i in {1..20}; do
    if kubectl wait --for=condition=available --timeout=30s deployment/argocd-server -n argocd 2>/dev/null; then
        echo "Argo CD is ready!"
        break
    else
        echo "Attempt $i/20: Argo CD not ready yet, waiting..."
        sleep 15
    fi
    if [ $i -eq 20 ]; then
        echo "ERROR: Argo CD failed to start after 10 minutes. Falling back to direct deployment."
        kubectl apply -f /home/tsoloher/Inception-of-things/p3/confs/deployement.yaml
        exit 0
    fi
done

# Get Argo CD admin password
echo "Getting Argo CD admin password..."
ARGOCD_PASSWORD=""
for i in {1..10}; do
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d 2>/dev/null)
    if [ ! -z "$ARGOCD_PASSWORD" ]; then
        break
    fi
    echo "Waiting for admin secret... ($i/10)"
    sleep 5
done

# Set up port forwarding for Argo CD UI
echo "Setting up port forwarding for Argo CD UI..."
nohup kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0 > /tmp/argocd-port-forward.log 2>&1 &

# Wait a bit for port-forward to be active
sleep 5

# Deploy application via direct YAML (more reliable than ArgoCD app)
echo "Deploying application directly..."
kubectl apply -f /home/tsoloher/Inception-of-things/p3/confs/deployement.yaml

# Wait for application deployment
echo "Waiting for application to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/wil-playground -n dev

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