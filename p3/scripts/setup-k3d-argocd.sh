#!/bin/bash

set -e

K3D_CLUSTER_NAME="mycluster"
ARGOCD_NAMESPACE="argocd"
APP_NAMESPACE="dev"
GITHUB_REPO="git@github.com:Tsunghao-C/IOT_test_deploy.git"
GITHUB_SSH_KEY_PATH="$HOME/.ssh/id_rsa"

# Create K3d cluster
echo "[LOG] Creating K3d cluster..."
k3d cluster create $K3D_CLUSTER_NAME --servers 1 --agents 1

# Create Namespaces
echo "[LOG] Creating namespaces..."
kubectl create namespace $ARGOCD_NAMESPACE
kubectl create namespace $APP_NAMESPACE

# Install ArgoCD
echo "[LOG] Install ArgoCD..."
kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "[LOG] Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/argocd-server -n $ARGOCD_NAMESPACE
# kubectl rollout status deployment/argocd-server -n $ARGOCD_NAMESPACE --timeout=120s

# Expose ArgoCD server
echo "[LOG] Exposing ArgoCD with port-forward..."
kubectl port-forward svc/argocd-server -n "$ARGOCD_NAMESPACE" 8080:443 > /dev/null 2>&1 &

# Get ArgoCD password
echo "[LOG] retrieve argocd password"
ARGO_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n $ARGOCD_NAMESPACE -o jsonpath="{.data.password}" | base64 --decode)

# Login to ArgoCD
echo "[LOG] Logging into ArgoCD..."
argocd login localhost:8080 --username admin --password $ARGO_PASSWORD --insecure

# Add Github repo
echo "[LOG] Adding Github repo to ArgoCD..."
argocd repo add $GITHUB_REPO --ssh-private-key-path $GITHUB_SSH_KEY_PATH

# Apply ArgoCD application manifest
echo "[LOG] Applying ArgoCD application..."
kubectl apply -f "./confs/app.yaml"

# # Verify Deployment
kubectl get pods -n $APP_NAMESPACE

echo "Setup complete! Access ArgoCD at: http://localhost:8080"
echo "Login with: admin | $ARGO_PASSWORD"