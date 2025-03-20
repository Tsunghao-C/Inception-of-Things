#!/bin/bash

sudo apt update -y

# Set up env for K3s
export INSTALL_K3S_EXEC="agent --server https://$1:6443 --token-file /vagrant/node-token --node-ip=$2"
sudo curl -sfL https://get.k3s.io | sh -
if [ $? -ne 0 ]; then
    echo "Failed to install K3s. Exiting."
    exit 1
fi

# alias k for kubectl
echo 'export PATH="/sbin:$PATH"' >> $HOME/.bashrc
echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-aliases.sh > /dev/null