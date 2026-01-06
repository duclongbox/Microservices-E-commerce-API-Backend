#!/bin/bash

# Build all Docker images for microservices
set -e

echo "================================================"
echo "Building Docker Images for Microservices"
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Services to build
services=("product-service" "order-service" "inventory-service" "notification-service" "api-gateway")

# Build each service
for service in "${services[@]}"; do
    echo -e "${YELLOW}Building $service...${NC}"

    if [ ! -d "$service" ]; then
        echo -e "${RED}Error: $service directory not found${NC}"
        exit 1
    fi

    cd "$service"

    # Build Docker image
    docker build -t "$service:latest" .

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Successfully built $service${NC}"
    else
        echo -e "${RED}✗ Failed to build $service${NC}"
        exit 1
    fi

    cd ..
    echo ""
done

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}All images built successfully!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "Built images:"
docker images | grep -E "(product-service|order-service|inventory-service|notification-service|api-gateway)" | grep latest
echo ""
echo -e "${YELLOW}Next step:${NC}"
echo "Load images to Kind: ./load-images-to-kind.sh"
