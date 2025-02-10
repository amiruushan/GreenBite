package com.greenbite.backend.controller;

import com.greenbite.backend.model.FoodShop;
import com.greenbite.backend.service.FoodShopService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/shop")
public class FoodShopController {
    @Autowired
    private FoodShopService foodShopService;

    @PostMapping("/add")
    public ResponseEntity<FoodShop> addFoodShop(@RequestBody FoodShop foodShop) {
        System.out.println("Wada karaanawa");
        FoodShop savedShop = foodShopService.saveFoodShop(foodShop);
        System.out.println("Wada karaanawa");
        return ResponseEntity.ok(savedShop);
    }
}
