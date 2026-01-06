# How to Run the Microservices Project


---

## Option 1: Development Mode (RECOMMENDED)

This is the **most common way for daily development** because it gives you:
- Hot reload (no rebuild needed)
- Easy debugging
- Fast iteration
- Access to IDE features

### Steps:

#### 1. Start Infrastructure Only
```bash
docker-compose -f docker-compose.infra.yml up -d
```

This starts:
- MongoDB (port 27017)
- MySQL (port 3306) - with both `inventory_service` and `order_service` databases
- Kafka + Zookeeper (port 9092)
- Schema Registry (port 8085)
- Kafka UI (port 8086)
- Keycloak (port 8181)

#### 2. Verify Infrastructure is Running
```bash
docker-compose -f docker-compose.infra.yml ps
```

All services should show "Up" and healthy.

#### 3. Run Services from Your IDE

You have **two options** for running services:

##### Option A: Run Each Service Separately (Most Flexible)
1. Open your IDE (IntelliJ IDEA, VS Code, Eclipse)
2. Navigate to each service's main class:
   - `product-service/src/main/java/.../ProductServiceApplication.java`
   - `inventory-service/src/main/java/.../InventoryServiceApplication.java`
   - `order-service/src/main/java/.../OrderServiceApplication.java`
   - `notification-service/src/main/java/.../NotificationServiceApplication.java`
   - `api-gateway/src/main/java/.../ApiGatewayApplication.java`

3. Right-click and select "Run" or "Debug"

4. Run them in this order (recommended):
   - **First**: product-service, inventory-service
   - **Second**: order-service (depends on inventory-service)
   - **Third**: notification-service (consumes from Kafka)
   - **Last**: api-gateway (routes to all services)

##### Option B: Use IDE Multi-Run Configuration
In IntelliJ IDEA:
1. Go to **Run → Edit Configurations**
2. Click **+** → **Compound**
3. Add all 5 services
4. Save as "Run All Microservices"
5. Click Run

#### 4. Verify Services are Running
```bash
# Check each service health
curl http://localhost:8080/actuator/health  # Product
curl http://localhost:8082/actuator/health  # Inventory
curl http://localhost:8081/actuator/health  # Order
curl http://localhost:9000/actuator/health  # Gateway


#### 6. Stop When Done
```bash
# Stop infrastructure
docker-compose -f docker-compose.infra.yml down

# Stop services from IDE (click Stop button)
```


---

##  Option 2: Docker Compose 

Use this when you want to test the **complete system** without Kubernetes complexity.

### Steps:

#### 1. Build Docker Images
```bash
./build-images.sh
```

This builds all 5 service images. Takes 5-10 minutes on first run (Maven downloads dependencies).

#### 2. Start Everything
```bash
docker-compose up -d
```

This starts:
- All infrastructure (MongoDB, MySQL, Kafka, etc.)
- All 5 microservices

#### 3. Check Status
```bash
docker-compose ps
```

Wait until all services are "Up" and healthy.

#### 4. View Logs
```bash
# View all logs
docker-compose logs -f

# View specific service
docker-compose logs -f api-gateway
docker-compose logs -f order-service
```

#### 5. Test the System
```bash
# Check health
curl http://localhost:9000/actuator/health

# Access Swagger UI
open http://localhost:9000/aggregate/swagger-ui.html

# Test inventory
curl "http://localhost:8082/api/inventory?skuCode=iphone_13&quantity=1"
```

#### 6. Stop Everything
```bash
docker-compose down
```

#### 7. Clean Up (Optional)
```bash
# Remove volumes (deletes all data)
docker-compose down -v
```


---

## 🎯 Option 3: Kubernetes with Kind

Use this to test **production-like deployment** with orchestration, scaling, and health checks.

### Steps:

#### 1. Create Kind Cluster
```bash
cd k8s
./setup-kind.sh
cd ..
```

This creates a cluster with 1 control-plane + 2 worker nodes.

#### 2. Build Docker Images
```bash
./build-images.sh
```

#### 3. Load Images to Kind
```bash
./load-images-to-kind.sh
```

This loads images into Kind's internal registry.

#### 4. Deploy Everything
```bash
cd k8s
./deploy-all.sh
```

This deploys:
- Infrastructure (Zookeeper, Kafka, MongoDB, MySQL, Keycloak)
- All 5 microservices with 2 replicas each (1 for notification)

#### 5. Check Status
```bash
# View all pods
kubectl get pods -n microservices

# Watch pod status
kubectl get pods -n microservices -w

# View services
kubectl get services -n microservices
```

#### 6. View Logs
```bash
# Single service
kubectl logs -f deployment/api-gateway -n microservices

# All replicas
kubectl logs -f -l app=order-service -n microservices
```

#### 7. Test the System
```bash
# Services are exposed via NodePort on same ports
curl http://localhost:9000/actuator/health
curl http://localhost:8082/api/inventory?skuCode=iphone_13&quantity=1
```

#### 8. Scale Services
```bash
# Scale product service to 5 replicas
kubectl scale deployment product-service --replicas=5 -n microservices

# Check status
kubectl get pods -l app=product-service -n microservices
```

#### 9. Update After Code Changes
```bash
# Rebuild and reload
./build-images.sh
./load-images-to-kind.sh

# Restart deployment
kubectl rollout restart deployment/product-service -n microservices
```

#### 10. Cleanup
```bash
# Delete all deployments
kubectl delete -f k8s/manifest/services/
kubectl delete -f k8s/manifest/infrastucture/

# Or delete entire cluster
kind delete cluster --name microservices-cluster
```



---

## Building from Root vs Individual Services

### Question: Should I build from root or build each service separately?

**Answer: Both approaches work. Choose based on your needs:**

### Approach 1: Multi-Module Build (Root POM)

I created a root `pom.xml` that allows building all services at once:

```bash
# From project root
mvn clean install

# This builds all 5 services in order
```

**When to use:**
- Initial project setup
- CI/CD pipelines
- Releasing multiple services
- Ensuring all services compile

### Approach 2: Individual Service Builds

Build each service independently:

```bash
# Build specific service
cd product-service
mvn clean package

cd ../order-service
mvn clean package
```

**When to use:**
- Daily development (only build what changed)
- Working on a single service
- Faster builds

**Note:** For **Option 1 (IDE development)**, you don't need to run Maven manually. The IDE builds automatically.

---

## Recommended Workflow Summary

### Day-to-Day Development:
```bash
# 1. Start infrastructure once
docker-compose -f docker-compose.infra.yml up -d

# 2. Run services from IDE (with hot reload)
# Make code changes, test immediately

# 3. Stop infrastructure when done
docker-compose -f docker-compose.infra.yml down
```

### Before Committing Code:
```bash
# 1. Build all services to ensure they compile
mvn clean install

# 2. Run tests
mvn test

# 3. (Optional) Test with Docker Compose
./build-images.sh
docker-compose up -d
# Run integration tests
docker-compose down
```

### Before Deployment:
```bash
# 1. Test in Kubernetes
cd k8s && ./setup-kind.sh && cd ..
./build-images.sh
./load-images-to-kind.sh
cd k8s && ./deploy-all.sh

# 2. Run integration and load tests

# 3. Clean up
kind delete cluster --name microservices-cluster
```

---



## MySQL Configuration Note

The project now uses a **single MySQL instance** instead of two separate instances:

- **Database 1:** `inventory_service` (Inventory Service)
- **Database 2:** `order_service` (Order Service)

Both databases are automatically created on startup via `docker/mysql/init.sql`.

**Ports:**
- Docker Compose: `localhost:3306`
- Kubernetes: `mysql:3306` (internal)

---



---


### Services won't start in IDE
```bash
# Make sure infrastructure is running
docker-compose -f docker-compose.infra.yml ps

# Check if ports are available
lsof -i :8080  # Product
lsof -i :8081  # Order
lsof -i :8082  # Inventory
lsof -i :9000  # Gateway
```

### Docker Compose fails
```bash
# Clean up and retry
docker-compose down -v
docker system prune -f
./build-images.sh
docker-compose up -d
```

### Kubernetes pods not starting
```bash
# Check logs
kubectl logs -f deployment/order-service -n microservices

# Describe pod
kubectl get pods -n microservices
kubectl describe pod <pod-name> -n microservices

# Verify images loaded
docker exec -it microservices-cluster-control-plane crictl images
```

---

## Summary

**Most Common Way:** Option 1 (Infrastructure in Docker + Services in IDE)
**Reason:** Fast iteration, easy debugging, hot reload

Only use Option 2 or 3 when you need to test the full containerized stack or Kubernetes features.
