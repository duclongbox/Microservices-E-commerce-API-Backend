-- Initialize databases for microservices
CREATE DATABASE IF NOT EXISTS inventory_service;
CREATE DATABASE IF NOT EXISTS order_service;

-- Grant privileges (optional, root already has access)
GRANT ALL PRIVILEGES ON inventory_service.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON order_service.* TO 'root'@'%';
FLUSH PRIVILEGES;

-- Show created databases
SHOW DATABASES;
