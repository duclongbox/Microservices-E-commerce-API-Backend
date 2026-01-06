#!/bin/bash

# Setup Kind Cluster for Microservices Architecture
set -e

echo "================================================"
echo "Setting up Kind Cluster for Microservices"
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if kind is installed
if ! command -v kind &> /dev/null; then
    echo -e "${RED}Error: kind is not installed${NC}"
    echo "Install kind from: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    echo "Install kubectl from: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker is not running${NC}"
    echo "Please start Docker and try again"
    exit 1
fi

echo -e "${YELLOW}Step 1: Cleaning up existing cluster (if any)...${NC}"
kind delete cluster --name microservices-cluster 2>/dev/null || true

echo -e "${YELLOW}Step 2: Creating Kind cluster...${NC}"
kind create cluster --config ../kind-config.yaml

echo -e "${YELLOW}Step 3: Waiting for cluster to be ready...${NC}"
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo -e "${YELLOW}Step 4: Creating namespace...${NC}"
kubectl create namespace microservices || true

echo -e "${YELLOW}Step 5: Setting default namespace...${NC}"
kubectl config set-context --current --namespace=microservices

echo -e "${GREEN}✓ Kind cluster setup complete!${NC}"
echo ""
echo "Cluster Information:"
kubectl cluster-info
echo ""
echo "Nodes:"
kubectl get nodes
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Build Docker images: ./build-images.sh"
echo "2. Load images into Kind: ./load-images-to-kind.sh"
echo "3. Deploy infrastructure: kubectl apply -f manifest/infrastructure/"
echo "4. Deploy services: kubectl apply -f manifest/services/"
echo ""
echo -e "${GREEN}To delete the cluster later, run:${NC}"
echo "kind delete cluster --name microservices-cluster"
