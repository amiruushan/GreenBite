package com.greenbite.backend.controller;

import com.greenbite.backend.dto.PurchaseCouponDTO;
import com.greenbite.backend.service.CouponManagementService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/user/inventory")
public class CouponManagementController {
    private final CouponManagementService couponManagementService;

    public CouponManagementController(CouponManagementService couponManagementService) {
        this.couponManagementService = couponManagementService;
    }

    @GetMapping("/{userId}")
    public List<Map<String, Object>> getUserCoupons(@PathVariable Long userId) {
        return couponManagementService.getUserCoupons(userId);
    }

    @PostMapping("/purchase-deal")
    public ResponseEntity<String> purchaseCoupon(@RequestBody PurchaseCouponDTO purchaseCouponDTO) {
        System.out.println("Coupon purchasing"+purchaseCouponDTO.getUserId()+"   "+purchaseCouponDTO.getCouponId());
        couponManagementService.purchaseCoupon(purchaseCouponDTO.getUserId(), purchaseCouponDTO.getCouponId(), purchaseCouponDTO.getCouponCode());
        return ResponseEntity.ok("Coupon purchased successfully!");
    }

    @PostMapping("/redeem-coupon")
    public ResponseEntity<String> redeemCoupon(@RequestBody Map<String, String> request) {
        String couponCode = request.get("couponCode");
        if (couponCode == null || couponCode.isEmpty()) {
            return ResponseEntity.badRequest().body("Coupon code is required");
        }

        try {
            couponManagementService.redeemCoupon(couponCode);
            return ResponseEntity.ok("Coupon redeemed successfully!");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}

