package com.example.demo.client;

import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.service.annotation.GetExchange;


public interface InventoryClient {
    @GetExchange("/api/inventory")
    Boolean isInStock(@RequestParam  String skuCode, @RequestParam Integer quantity);
}



// spring cloud openfeign help us to delclare a client to communicate with other microservices
// instead of constructing rest template every time we want to communicate with other microservices