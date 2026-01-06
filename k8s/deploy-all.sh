#!/bin/bash

# Deploy all services to Kubernetes
set -e

echo "================================================"
echo "Deploying Microservices to Kubernetes"
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: kubectl is not configured or cluster is not accessible${NC}"
    exit 1
fi

# Create namespace if it doesn't exist
echo -e "${YELLOW}Creating namespace 'microservices'...${NC}"
kubectl create namespace microservices --dry-run=client -o yaml | kubectl apply -f -

# Set namespace as default
kubectl config set-context --current --namespace=microservices

echo ""
echo -e "${BLUE}Step 1: Deploying Infrastructure...${NC}"
echo "================================================"

# Deploy infrastructure in order
echo -e "${YELLOW}Deploying Zookeeper...${NC}"
kubectl apply -f manifest/infrastucture/zookeeper.yml

echo -e "${YELLOW}Waiting for Zookeeper to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=zookeeper --timeout=120s -n microservices

echo -e "${YELLOW}Deploying Kafka...${NC}"
kubectl apply -f manifest/infrastucture/kafka.yml

echo -e "${YELLOW}Waiting for Kafka to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=broker --timeout=120s -n microservices

echo -e "${YELLOW}Deploying Schema Registry...${NC}"
kubectl apply -f manifest/infrastucture/schema-registry.yml

echo -e "${YELLOW}Deploying Kafka UI...${NC}"
kubectl apply -f manifest/infrastucture/kafka-ui.yml

echo -e "${YELLOW}Deploying MongoDB...${NC}"
kubectl apply -f manifest/infrastucture/mongodb.yml

echo -e "${YELLOW}Waiting for MongoDB to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=120s -n microservices

echo -e "${YELLOW}Deploying MySQL database...${NC}"
kubectl apply -f manifest/infrastucture/mysql.yml

echo -e "${YELLOW}Waiting for MySQL to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=mysql --timeout=120s -n microservices || true

echo -e "${YELLOW}Deploying Keycloak...${NC}"
kubectl apply -f manifest/infrastucture/keycloak.yml

echo -e "${GREEN}✓ Infrastructure deployed${NC}"
echo ""

echo -e "${BLUE}Step 2: Deploying Microservices...${NC}"
echo "================================================"

# Deploy services
services=("product-service" "inventory-service" "order-service" "notification-service" "api-gateway")

for service in "${services[@]}"; do
    echo -e "${YELLOW}Deploying $service...${NC}"
    kubectl apply -f "manifest/services/$service.yaml"
done

echo -e "${GREEN}✓ All services deployed${NC}"
echo ""

echo -e "${BLUE}Step 3: Waiting for services to be ready...${NC}"
echo "================================================"

# Wait for deployments to be ready
for service in "${services[@]}"; do
    echo -e "${YELLOW}Waiting for $service...${NC}"
    kubectl wait --for=condition=available deployment/$service --timeout=180s -n microservices || true
done

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${BLUE}Cluster Status:${NC}"
kubectl get pods -n microservices
echo ""
echo -e "${BLUE}Service Endpoints:${NC}"
kubectl get services -n microservices
echo ""
echo -e "${YELLOW}Access URLs (after port-forwarding or NodePort):${NC}"
echo "API Gateway:         http://localhost:9000"
echo "Product Service:     http://localhost:8080"
echo "Order Service:       http://localhost:8081"
echo "Inventory Service:   http://localhost:8082"
echo "Notification Service: http://localhost:8083"
echo "Keycloak:            http://localhost:8181"
echo "Kafka UI:            http://localhost:8086"
echo ""
echo -e "${YELLOW}To check logs:${NC}"
echo "kubectl logs -f deployment/<service-name> -n microservices"
echo ""
echo -e "${YELLOW}To undeploy:${NC}"
echo "kubectl delete -f manifest/services/"
echo "kubectl delete -f manifest/infrastucture/"
