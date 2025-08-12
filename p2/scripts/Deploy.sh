#!/bin/bash

echo "Deploying applications..."

# List available configuration files for debugging
echo "Available configuration files:"
find /vagrant/confs -name "*.yaml" -type f | sort

# Apply ConfigMaps first
echo "Creating ConfigMaps..."
kubectl apply -f /vagrant/confs/app1/app1-configmap.yaml
kubectl apply -f /vagrant/confs/app2/app2-configmap.yaml
kubectl apply -f /vagrant/confs/app3/app3-configmap.yaml

# Apply Deployments
echo "Creating Deployments..."
kubectl apply -f /vagrant/confs/app1/app1-deployment.yaml
kubectl apply -f /vagrant/confs/app2/app2-deployment.yaml
kubectl apply -f /vagrant/confs/app3/app3-deployment.yaml

# Apply Services
echo "Creating Services..."
kubectl apply -f /vagrant/confs/app1/app1-service.yaml
kubectl apply -f /vagrant/confs/app2/app2-service.yaml
kubectl apply -f /vagrant/confs/app3/app3-service.yaml

# Apply Ingress
echo "Creating Ingress..."
kubectl apply -f /vagrant/confs/ingress.yaml

echo "Waiting for deployments to be ready..."

# Wait for deployments to be available
kubectl wait --for=condition=available --timeout=300s deployment/app1-deployment
kubectl wait --for=condition=available --timeout=300s deployment/app2-deployment
kubectl wait --for=condition=available --timeout=300s deployment/app3-deployment

echo "Waiting for pods to be ready..."

# Wait for all pods to be running
kubectl wait --for=condition=ready pod --all --timeout=300s

echo "Checking deployment status..."

# Show status
echo "=== CONFIGMAPS ==="
kubectl get configmaps

echo "=== NODES ==="
kubectl get nodes -o wide

echo "=== PODS ==="
kubectl get pods -o wide

echo "=== SERVICES ==="
kubectl get services

echo "=== INGRESS ==="
kubectl get ingress

echo "=== ENDPOINTS ==="
kubectl get endpoints

echo "Deployment completed!"
echo ""
echo "To test the applications:"
echo "1. Add to your /etc/hosts file:"
echo "   192.168.56.110 app1.com app2.com"
echo ""
echo "2. Test with curl or browser:"
echo "   curl http://app1.com"
echo "   curl http://app2.com"
echo "   curl http://192.168.56.110"