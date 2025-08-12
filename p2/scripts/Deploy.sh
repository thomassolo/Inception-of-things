#!/bin/bash

#!/bin/bash
kubectl apply -f /vagrant/confs/
kubectl wait --for=condition=ready pod --all --timeout=300s

kubectl apply -f app1-deployment.yaml
kubectl apply -f app1-service.yaml

kubectl apply -f app2-deployment.yaml
kubectl apply -f app2-service.yaml

kubectl apply -f app3-deployment.yaml
kubectl apply -f app3-service.yaml

kubectl apply -f ingress.yaml