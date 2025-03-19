#!/bin/bash

sudo apt-get update
sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode=644 --node-ip $1 --bind-address=$1" sh -s -
sleep 15
cp /var/lib/rancher/k3s/server/node-token /vagrant/.