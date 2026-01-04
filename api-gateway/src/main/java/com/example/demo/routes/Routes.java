package com.example.demo.routes;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.function.*;


import static org.springframework.cloud.gateway.server.mvc.filter.BeforeFilterFunctions.uri;
import static org.springframework.cloud.gateway.server.mvc.filter.FilterFunctions.rewritePath;
import static org.springframework.cloud.gateway.server.mvc.handler.GatewayRouterFunctions.route;
import static org.springframework.cloud.gateway.server.mvc.handler.HandlerFunctions.http;

@Configuration
public class Routes {
    @Bean
    public RouterFunction<ServerResponse> productServiceRoute() {
        return route("product_route")
                .route(RequestPredicates.path("/api/product"), http())
                .before(uri("http://localhost:8080"))
                .build();
    }
    @Bean
    public RouterFunction<ServerResponse> productServiceSwaggerRoute() {
        return route("product_service_swagger_route")
                .route(RequestPredicates.path("/aggregate/product-service/v3/api-docs"), http())
                .before(uri("http://localhost:8080"))
                .filter(rewritePath("/aggregate/product-service/v3/api-docs", "/api-docs"))
                .build();
    }

    @Bean
    public RouterFunction<ServerResponse> inventoryServiceRoute() {
        return route("inventory_route")
                .route(RequestPredicates.path("/api/inventory"), http())
                .before(uri("http://localhost:8082"))
                .build();
    }
    @Bean
    public RouterFunction<ServerResponse> inventoryServiceSwaggerRoute() {
        return route("inventory_service_swagger_route")
                .route(RequestPredicates.path("/aggregate/inventory-service/v3/api-docs"), http())
                .before(uri("http://localhost:8080"))
                .filter(rewritePath("/aggregate/inventory-service/v3/api-docs", "/api-docs"))
                .build();
    }

    @Bean
    public RouterFunction<ServerResponse> orderServiceRoute() {
        return route("order_route")
                .route(RequestPredicates.path("/api/order"), http())
                .before(uri("http://localhost:8081"))
                .build();
    }
    @Bean
    public RouterFunction<ServerResponse> orderServiceSwaggerRoute() {
        return route("order_service_swagger_route")
                .route(RequestPredicates.path("/aggregate/order-service/v3/api-docs"), http())
                .before(uri("http://localhost:8080"))
                .filter(rewritePath("/aggregate/order-service/v3/api-docs", "/api-docs"))
                .build();
    }
}
