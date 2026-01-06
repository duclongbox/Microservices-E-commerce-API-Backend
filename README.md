
# Architecture Overview

### Microservices
- **API Gateway** (Port 9000) - Entry point with JWT authentication & circuit breaker
- **Product Service** (Port 8080) - Product catalog management (MongoDB)
- **Order Service** (Port 8081) - Order processing (MySQL + Kafka)
- **Inventory Service** (Port 8082) - Inventory management (MySQL)
- **Notification Service** (Port 8083) - Email notifications via Kafka

### Infrastructure
- **MongoDB** (Port 27017) - Product Service database
- **MySQL Inventory** (Port 3306) - Inventory Service database
- **MySQL Order** (Port 3316) - Order Service database
- **Kafka** (Port 9092) - Event streaming
- **Zookeeper** (Port 2181) - Kafka coordination
- **Schema Registry** (Port 8085) - Kafka schema management
- **Kafka UI** (Port 8086) - Kafka monitoring
- **Keycloak** (Port 8181) - Authentication & authorization


### Access Services

Services are exposed via NodePort on these URLs:

- **API Gateway:** http://localhost:9000
- **Product Service:** http://localhost:8080
- **Order Service:** http://localhost:8081
- **Inventory Service:** http://localhost:8082
- **Keycloak:** http://localhost:8181
- **Kafka UI:** http://localhost:8086

