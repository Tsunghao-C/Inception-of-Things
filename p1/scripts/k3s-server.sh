#!/bin/bash

sudo apt update -y

# Set up env for K3s
export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC="server --node-ip $1 --bind-address=$1"
# Install K3s
echo "[LOG] Installing K3s"
sudo curl -sfL https://get.k3s.io | sh -
if [ $? -ne 0 ]; then
    echo "Failed to install K3s. Exiting."
    exit 1
fi
echo "[LOG] Copy token"
TIMEOUT=30
while [ ! -f  /var/lib/rancher/k3s/server/node-token ]; do
    sleep 1
    TIMEOUT=$((TIMEOUT - 1))
    if [ "$TIMEOUT" -eq 0 ]; then
        echo "Token file failed to generate."
        exit 1
    fi
done
cp /var/lib/rancher/k3s/server/node-token /vagrant/.

# alias k for kubectl
echo 'export PATH="/sbin:$PATH"' >> $HOME/.bashrc
echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-aliases.sh > /dev/null