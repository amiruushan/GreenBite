package com.greenbite.backend.controller;

import com.greenbite.backend.dto.FoodShopDTO;
import com.greenbite.backend.model.FoodShop;
import com.greenbite.backend.service.FoodShopService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLOutput;
import java.util.List;

@RestController
@RequestMapping("api/shop")
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
    @GetMapping("/all")
    public ResponseEntity<List<FoodShopDTO>> getAllFoodShops() {
        List<FoodShopDTO> shops = foodShopService.getAllFoodShops();
        return ResponseEntity.ok(shops);
    }
    @GetMapping("/{id}")
    public FoodShopDTO getFoodShopById(@PathVariable Long id){
        System.out.println("work");
        return foodShopService.getFoodShopById(id);
    }
    @GetMapping("/nearby")
    public List<FoodShop> findNearbyShops(
            @RequestParam double lat,
            @RequestParam double lon,
            @RequestParam(defaultValue = "5") double radius) {
        System.out.println("hhhh");
        return foodShopService.findShopsNearby(lat, lon, radius);
    }
}
