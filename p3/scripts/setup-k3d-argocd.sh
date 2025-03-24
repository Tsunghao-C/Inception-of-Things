#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

set -e

ARGOCD_NAMESPACE="argocd"
APP_NAMESPACE="dev"
GITHUB_REPO="git@github.com:Tsunghao-C/IOT_test_deploy.git"
GITHUB_SSH_KEY_PATH="$HOME/.ssh/id_rsa"

# Create K3d cluster
echo -e "${GREEN}[LOG] Creating K3d cluster...${NC}\n"
k3d cluster create $USERNAME --servers 1 --agents 2

# Create Namespaces
echo -e "${GREEN}[LOG] Creating namespaces...${NC}\n"
kubectl create namespace $ARGOCD_NAMESPACE
kubectl create namespace $APP_NAMESPACE

# Install ArgoCD
echo -e "${GREEN}[LOG] Install ArgoCD...${NC}\n"
kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo -e "${YELLOW}[LOG] Waiting for ArgoCD to be ready...${NC}\n"
kubectl wait --for=condition=available --timeout=120s deployment/argocd-server -n $ARGOCD_NAMESPACE
# kubectl rollout status deployment/argocd-server -n $ARGOCD_NAMESPACE --timeout=120s

# Expose ArgoCD server
echo -e "${GREEN}[LOG] Exposing ArgoCD with port-forward...${NC}\n"
kubectl port-forward svc/argocd-server -n "$ARGOCD_NAMESPACE" 8080:443 > /dev/null 2>&1 &

# Get ArgoCD password
echo -e "${GREEN}[LOG] retrieve argocd password${NC}\n"
ARGO_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n $ARGOCD_NAMESPACE -o jsonpath="{.data.password}" | base64 --decode)

# Login to ArgoCD
echo -e "${GREEN}[LOG] Logging into ArgoCD...${NC}\n"
argocd login localhost:8080 --username admin --password $ARGO_PASSWORD --insecure

# Add Github repo
echo -e "${GREEN}[LOG] Adding Github repo to ArgoCD...${NC}\n"
argocd repo add $GITHUB_REPO --ssh-private-key-path $GITHUB_SSH_KEY_PATH

# Apply ArgoCD application manifest
echo -e "${GREEN}[LOG] Applying ArgoCD application...${NC}\n"
kubectl apply -f "./confs/app.yaml"

# # Verify Deployment (wait for 10 sec for ArgoCD to setup)
sleep 10
kubectl get pods -n $APP_NAMESPACE

echo -e "${GREEN}Setup complete!${NC} Access ArgoCD at: http://localhost:8080\n"
echo -e "Login with: ${YELLOW}admin | $ARGO_PASSWORD${NC}\n"