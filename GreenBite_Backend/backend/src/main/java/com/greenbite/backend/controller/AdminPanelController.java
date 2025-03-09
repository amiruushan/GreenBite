package com.greenbite.backend.controller;

import com.greenbite.backend.dto.FoodShopDTO;
import com.greenbite.backend.dto.UserDTO;
import com.greenbite.backend.model.Coupon;
import com.greenbite.backend.service.FoodShopService;
import com.greenbite.backend.service.UserService;
import com.greenbite.backend.service.CouponService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminPanelController {

    private final UserService userService;
    private final FoodShopService foodShopService;
    private final CouponService couponService;  // Added CouponService

    public AdminPanelController(UserService userService, FoodShopService foodShopService, CouponService couponService) {
        this.userService = userService;
        this.foodShopService = foodShopService;
        this.couponService = couponService;
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

    // Getting all food shops
    @GetMapping("/listFoodShops")
    public ResponseEntity<List<FoodShopDTO>> getAllFoodShopsAdmin() {
        List<FoodShopDTO> shops = foodShopService.getAllFoodShopsAdmin();
        return ResponseEntity.ok(shops);
    }

    // Deleting food shop
    @DeleteMapping("/deleteFoodShop/{foodShopId}")
    public ResponseEntity<String> deleteFoodShop(@PathVariable Long foodShopId) {
        foodShopService.deleteFoodShopById(foodShopId);
        return ResponseEntity.ok("Food Shop deleted successfully");
    }

    // Creating a new coupon
    @PostMapping("/createCoupon")
    public ResponseEntity<String> createCoupon(@RequestBody Coupon coupon) {
        couponService.createCoupon(coupon);  // Delegate to CouponService
        return ResponseEntity.ok("Coupon created successfully");
    }

    // Deleting a coupon by ID
    @DeleteMapping("/deleteCoupon/{couponId}")
    public ResponseEntity<String> deleteCoupon(@PathVariable Long couponId) {
        couponService.deleteCouponById(couponId);  // Delegate to CouponService
        return ResponseEntity.ok("Coupon deleted successfully");
    }
}
