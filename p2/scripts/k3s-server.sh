#!/bin/bash

apt update -y

# Install K3s
echo "[Step 1] Installing K3s..."
export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC="server --node-external-ip=$1 --bind-address=$1 --flannel-iface=eth1"
sudo curl -sfL https://get.k3s.io | sh -
if [ $? -ne 0 ]; then
    echo "Failed to install K3s. Exiting."
    exit 1
fi

sleep 10

# alias k for kubectl
echo 'export PATH="/sbin:$PATH"' >> $HOME/.bashrc
echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-aliases.sh > /dev/null

# Deploy Applications
echo "[Step 2] Deploying Applications"

echo "[App1] Deploying"
kubectl create configmap app-one-html --from-file /vagrant/app1/index.html
kubectl apply -f /vagrant/app1/deployment.yaml
kubectl apply -f /vagrant/app1/service.yaml
echo "[App1] Done"

echo "[App2] Deploying"
kubectl create configmap app-two-html --from-file /vagrant/app2/index.html
kubectl apply -f /vagrant/app2/deployment.yaml
kubectl apply -f /vagrant/app2/service.yaml
echo "[App2] Done"

echo "[App3] Deploying"
kubectl create configmap app-three-html --from-file /vagrant/app3/index.html
kubectl apply -f /vagrant/app3/deployment.yaml
kubectl apply -f /vagrant/app3/service.yaml
echo "[App3] Done"

echo "[Ingress] Deploying"
kubectl apply -f /vagrant/ingress.yaml
echo "[Ingress] Done"

sleep 5

# Check deployments
echo "Checking Deployments...."
kubectl get deployments
echo "Checking Ingress...."
kubectl get ingress