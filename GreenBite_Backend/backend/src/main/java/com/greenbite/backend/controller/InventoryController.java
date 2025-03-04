package com.greenbite.backend.controller;

import com.greenbite.backend.dto.PurchaseDealDTO;
import com.greenbite.backend.service.InventoryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/user/inventory")
public class InventoryController {
    private final InventoryService inventoryService;

    public InventoryController(InventoryService inventoryService) {
        this.inventoryService = inventoryService;
    }

    @GetMapping("/{userId}")
    public List<Map<String, Object>> getUserInventory(@PathVariable Long userId) {
        return inventoryService.getUserInventory(userId);
    }

    @PostMapping("/purchase-deal")
    public ResponseEntity<String> purchaseDeal(@RequestBody PurchaseDealDTO purchaseDealDTO) {
        inventoryService.purchaseDeal(purchaseDealDTO.getUserId(), purchaseDealDTO.getDealId(), purchaseDealDTO.getCouponCode());
        return ResponseEntity.ok("Deal purchased successfully!");
    }

    @PostMapping("/redeem-coupon")
    public ResponseEntity<String> redeemCoupon(@RequestBody Map<String, String> request) {
        String couponCode = request.get("couponCode");
        if (couponCode == null || couponCode.isEmpty()) {
            return ResponseEntity.badRequest().body("Coupon code is required");
        }

        try {
            inventoryService.redeemCoupon(couponCode);
            return ResponseEntity.ok("Coupon redeemed successfully!");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}