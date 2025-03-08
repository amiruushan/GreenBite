package com.greenbite.backend.controller;

import com.greenbite.backend.dto.FoodShopDTO;
import com.greenbite.backend.dto.UserDTO;
import com.greenbite.backend.service.FoodShopService;
import com.greenbite.backend.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
@RestController
@RequestMapping("/api/admin")

public class AdminPanelController {

    private final UserService userService;
    private final FoodShopService foodShopService;

    public AdminPanelController(UserService userService, FoodShopService foodShopService) {
        this.userService=userService;
        this.foodShopService=foodShopService;
    }

    @GetMapping("/listUsers")
    public ResponseEntity<List<UserDTO>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @DeleteMapping("/deleteUser/{userId}")
    public ResponseEntity<String> deleteUser(@PathVariable Long userId) {
        userService.deleteUserById(userId);
        return ResponseEntity.ok("User deleted successfully");
    }

    // getting all food shop
    @GetMapping("/listFoodShops")
    public ResponseEntity<List<FoodShopDTO>> getAllFoodShopsAdmin() {
        System.out.print("work work work");
        List<FoodShopDTO> shops = foodShopService.getAllFoodShops();
        return ResponseEntity.ok(shops);

    }
}