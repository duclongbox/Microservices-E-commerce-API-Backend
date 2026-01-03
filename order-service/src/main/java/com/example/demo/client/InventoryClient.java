package com.example.demo.client;


import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(name="inventory", url="${inventory.service.url}")
public interface InventoryClient {

    @RequestMapping(method = RequestMethod.GET,value = "/api/inventory")
    Boolean isInStock(@RequestParam  String skuCode, @RequestParam Integer quantity);
}



// spring cloud openfeign help us to delclare a client to communicate with other microservices
// instead of constructing rest template every time we want to communicate with other microservices