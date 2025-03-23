package com.greenbite.backend.controller;

import com.greenbite.backend.dto.FoodShopDTO;
import com.greenbite.backend.model.FoodShop;
import com.greenbite.backend.service.FoodShopService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.sql.SQLOutput;
import java.util.List;

@RestController
@RequestMapping("api/shop")
public class FoodShopController {
    @Autowired
    private FoodShopService foodShopService;

    @PostMapping("/add")
    public ResponseEntity<FoodShop> addFoodShop(@RequestBody FoodShop foodShop) {
        FoodShop savedShop = foodShopService.saveFoodShop(foodShop);
        return ResponseEntity.ok(savedShop);
    }
    @GetMapping("/all")
    public ResponseEntity<List<FoodShopDTO>> getAllFoodShops() {
        List<FoodShopDTO> shops = foodShopService.getAllFoodShops();
        return ResponseEntity.ok(shops);
    }
    @GetMapping("/{id}")
    public FoodShopDTO getFoodShopById(@PathVariable Long id) {
        return foodShopService.getFoodShopById(id);
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<FoodShop> updateFoodShop(
            @PathVariable Long id,
            @RequestPart("shop") String shopJson,
            @RequestPart(value = "photo", required = false) MultipartFile photo) throws IOException {

        FoodShop updatedShop = foodShopService.updateFoodShop(id, shopJson, photo);
        return ResponseEntity.ok(updatedShop);
    }

    @GetMapping("/nearby")
    public List<FoodShop> findNearbyShops(
            @RequestParam double lat,
            @RequestParam double lon,
            @RequestParam(defaultValue = "5") double radius) {
        System.out.println("Shop latitude: "+lat);
        System.out.println("Shop latitude: "+lon);
        List<FoodShop> nearbyShops = foodShopService.findShopsNearby(lat, lon, radius);

        // Print the returned values
        System.out.println("Found shops: " + nearbyShops);

        return nearbyShops;
    }


}
