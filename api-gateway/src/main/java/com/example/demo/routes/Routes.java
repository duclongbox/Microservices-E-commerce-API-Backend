package com.example.demo.routes;

import org.springframework.cloud.gateway.server.mvc.filter.CircuitBreakerFilterFunctions;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.servlet.function.*;


import java.net.URI;
import java.time.LocalDateTime;
import java.util.Map;

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
                .filter(CircuitBreakerFilterFunctions.circuitBreaker("productServiceCircuitBreaker",
                        URI.create("forward:/fallbackRoute")))
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
                .filter(CircuitBreakerFilterFunctions.circuitBreaker("inventoryServiceCircuitBreaker",
                        URI.create("forward:/fallbackRoute")))
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
                .filter(CircuitBreakerFilterFunctions.circuitBreaker("orderServiceCircuitBreaker",
                        URI.create("forward:/fallbackRoute")))
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

    @Bean
    public RouterFunction<ServerResponse> fallBackRoute() {
        return route("fallbackRoute")
                .route(RequestPredicates.path("/fallbackRoute"), request ->  // Changed: Use .route() for all methods, path is /fallback
                        ServerResponse.status(HttpStatus.SERVICE_UNAVAILABLE)
                                .contentType(MediaType.APPLICATION_JSON)
                                .body(Map.of(
                                        "error", "Service Unavailable",
                                        "message", "The requested service is currently unavailable. Please try again later.",
                                        "timestamp", LocalDateTime.now().toString()
                                ))
                )
                .build();
    }
}
