package com.greenbite.backend.controller;

import com.greenbite.backend.dto.FoodItemDTO;
import com.greenbite.backend.dto.FoodShopDTO;
import com.greenbite.backend.dto.UserDTO;
import com.greenbite.backend.model.Coupon;
import com.greenbite.backend.service.FoodItemService;
import com.greenbite.backend.service.FoodShopService;
import com.greenbite.backend.service.UserService;
import com.greenbite.backend.service.CouponService;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@AllArgsConstructor
@RequestMapping("/api/admin")
public class AdminPanelController {

    private final UserService userService;
    private final FoodShopService foodShopService;
    private final CouponService couponService;
    private final FoodItemService foodItemService;

    @GetMapping("/listUsers")
    public ResponseEntity<List<UserDTO>> getAllUsers() {
        System.out.println("Wada karaanawa");
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

    //Listing all the coupon
    @GetMapping("/listAllCoupon")
    public List<Coupon> getAllCoupons() {
        System.out.println("Wada karaanawa");
        return couponService.getAllCoupons();
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

    @DeleteMapping("/delete")
    public void deleteFoodItem(@RequestBody FoodItemDTO foodItemDTO){
        foodItemService.deleteFoodItem(foodItemDTO);
    }

    @GetMapping("/listFoodItems/{foodShopId}")
    public ResponseEntity<List<FoodItemDTO>> getFoodItemsByShop(@PathVariable Long foodShopId) {
        List<FoodItemDTO> foodItems = foodItemService.getFoodItemsByShop(foodShopId);
        return ResponseEntity.ok(foodItems);
    }
    @GetMapping("/expiredFoodShops")
    public ResponseEntity<List<FoodShopDTO>> getExpiredFoodShops() {
        List<FoodShopDTO> expiredShops = foodShopService.getExpiredLicenseShops();
        return ResponseEntity.ok(expiredShops);
    }


}

