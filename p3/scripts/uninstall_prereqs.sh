#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# check permissions
if [ "$(id -u)" -ne 0 ] && [ -z "$SUDO_UID" ] && [ -z "$SUDO_USER" ]; then
	printf "${RED}[LINUX]${NC} - Permission denied. Please run the command with sudo privileges.\n"
	exit 87
fi

# Remove K3d Cluster (if exists)
printf "${YELLOW}[K3D]${NC} - Deleting K3d cluster (if any)...\n"
for cluster in $(k3d cluster list -o json | jq -r '.[].name'); do
	k3d cluster delete "$cluster"
done

# Uninstall K3d
printf "${YELLOW}[K3D]${NC} - Removing K3d...\n"
rm -rf /usr/local/bin/k3d

# Uninstall ArgoCD CLI
printf "${YELLOW}[ARGOCD]${NC} - Removing ArgoCD CLI...\n"
rm -rf /usr/local/bin/argocd

# Uninstall Kubectl
printf "${YELLOW}[KUBECTL]${NC} - Removing kubectl...\n"
rm -rf /usr/local/bin/kubectl

# # Uninstall Helm
# printf "${YELLOW}[HELM]${NC} - Removing Helm...\n"
# rm -rf /usr/local/bin/helm
# rm -rf ~/.helm
# rm -rf /etc/helm
# rm -rf /usr/local/share/helm
# rm -rf /usr/local/lib/helm

# Uninstall Curl
printf "${YELLOW}[CURL]${NC} - Removing Curl...\n"
apt-get remove -y curl

# Uninstall Docker
printf "${YELLOW}[DOCKER]${NC} - Removing Docker and related components...\n"
apt-get remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
rm -rf /var/lib/docker
rm -rf /var/lib/containerd

# Clean up remaining files
printf "${YELLOW}[CLEANUP]${NC} - Cleaning up system...\n"
apt-get autoremove -y
apt-get autoclean -y

# Remove Docker's keyring and repository
rm -rf /etc/apt/keyrings/docker.gpg
rm -rf /etc/apt/sources.list.d/docker.list

# Remove Kubernetes repo (if added)
rm -rf /etc/apt/sources.list.d/kubernetes.list

printf "${GREEN}[DONE]${NC} - Everything has been removed. System is clean!\n"
