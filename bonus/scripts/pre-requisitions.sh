#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Function to check if a command exists and install if not
check_install() {
  local name=$1
  local command=$2
  local install_command=$3

  if $command &> /dev/null
  then
    echo -e "${GREEN}- $name is installed ${NC}\n"
  else
    echo -e "${YELLOW}- $name is not installed. Installing...${NC}\n"
    eval $install_command
    echo -e "${GREEN} $name has been successfully installed ${NC}\n"
  fi
}

# check permissions
if [ "$(id -u)" -ne 0 ] && [ -z "$SUDO_UID" ] && [ -z "$SUDO_USER" ]; then
	printf "${RED}[LINUX]${NC} - Permission denied. Please run the command with sudo privileges.\n"
	exit 87
fi

# basic config
printf "${GREEN}[LINUX]${NC} - Getting updates...\n"
apt-get update > /dev/null

# curl
printf "${GREEN}[CURL]${NC} - Installing curl...\n"
check_install "curl" "curl --version" "apt-get install -y curl"

# docker
printf "${GREEN}[DOCKER]${NC} - Installing docker...\n"
if ! command -v docker &> /dev/null; then
	sudo apt-get update
	sudo apt-get install ca-certificates
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
		$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	echo -e "${GREEN} Docker has been successfully installed ${NC}\n"
else
	printf "${YELLOW}[DOCKER]${NC} - Docker is already installed.\n"
fi

# kubectl
printf "${GREEN}[KUBECTL]${NC} - Installing kubectl...\n"
check_install "kubectl" "kubectl version --client" "
curl -LO \"https://dl.k8s.io/release/\$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl\"
&& chmod +x kubectl
&& mv kubectl /usr/local/bin/
"

# install k3d
printf "${GREEN}[K3D]${NC} - Installing K3d...\n"
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# install argocd CLI
printf "${GREEN}[ARGOCD]${NC} - Installing ArgoCD CLI...\n"
check_install "argocd" "argocd version" "
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
&& chmod +x /usr/local/bin/argocd
"

# install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
