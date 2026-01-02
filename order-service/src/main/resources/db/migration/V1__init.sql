CREATE TABLE `t_orders`
(
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `order_number` varchar(255) DEFAULT NULL,
    `sku_code` varchar(255) ,
    `price` DECIMAL(19,2) ,
    `quantity` INT(11) ,
    PRIMARY KEY (`id`)
)

--even re run the application, flyway will not try to re apply this script
-- because it keeps track of applied migrations in a special table called `flyway_schema_history`.