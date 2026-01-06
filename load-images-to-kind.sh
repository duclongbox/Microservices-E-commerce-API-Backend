#!/bin/bash

# Load Docker images into Kind cluster
set -e

echo "================================================"
echo "Loading Docker Images into Kind Cluster"
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

CLUSTER_NAME="microservices-cluster"

# Check if kind cluster exists
if ! kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo -e "${RED}Error: Kind cluster '$CLUSTER_NAME' not found${NC}"
    echo "Please run: cd k8s && ./setup-kind.sh"
    exit 1
fi

# Services to load
services=("product-service" "order-service" "inventory-service" "notification-service" "api-gateway")

# Load each service image into Kind
for service in "${services[@]}"; do
    echo -e "${YELLOW}Loading $service:latest into Kind...${NC}"

    # Check if image exists
    if ! docker images | grep -q "$service.*latest"; then
        echo -e "${RED}Error: Image $service:latest not found${NC}"
        echo "Please run: ./build-images.sh"
        exit 1
    fi

    # Load image into Kind cluster
    kind load docker-image "$service:latest" --name "$CLUSTER_NAME"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Successfully loaded $service${NC}"
    else
        echo -e "${RED}✗ Failed to load $service${NC}"
        exit 1
    fi
    echo ""
done

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}All images loaded into Kind successfully!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Deploy infrastructure: kubectl apply -f k8s/manifest/infrastucture/"
echo "2. Wait for infrastructure: kubectl wait --for=condition=ready pod -l app=mongodb --timeout=300s -n microservices"
echo "3. Deploy services: kubectl apply -f k8s/manifest/services/"
echo "4. Check status: kubectl get pods -n microservices"
