#!/bin/bash

# Install K3s
echo "[Step 1] Installing K3s..."
sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode=644 --node-ip $1 --bind-address=$1" sh -s -
sleep 10

# Deploy Applications
echo "[Step 2] Deploying Applications"
kubectl apply -f /vagrant/confs/services.yaml
sleep 7
kubectl apply -f /vagrant/confs/deployments.yaml
sleep 7
kubectl apply -f /vagrant/confs/ingress.yaml
sleep 7

echo "[Step 3] Checking Deployments...."
kubectl get deployments

echo "[Step 4] Checking Ingress...."
kubectl get ingress