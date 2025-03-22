package com.greenbite.backend.service;

import com.greenbite.backend.model.Coupon;
import com.greenbite.backend.model.CouponManagement;
import com.greenbite.backend.model.User;
import com.greenbite.backend.repository.CouponManagementRepository;
import com.greenbite.backend.repository.CouponRepository;
import com.greenbite.backend.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class CouponManagementService {
    private final CouponManagementRepository couponManagementRepository;
    private final UserRepository userRepository;
    private final CouponRepository couponRepository;

    public CouponManagementService(CouponManagementRepository couponManagementRepository, UserRepository userRepository, CouponRepository couponRepository) {
        this.couponManagementRepository = couponManagementRepository;
        this.userRepository = userRepository;
        this.couponRepository = couponRepository;
    }

    public List<Map<String, Object>> getUserCoupons(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<CouponManagement> couponItems = couponManagementRepository.findByUser(user);
        List<Map<String, Object>> couponData = new ArrayList<>();

        for (CouponManagement item : couponItems) {
            Map<String, Object> map = new HashMap<>();
            map.put("coupon_name", item.getCoupon().getTitle());
            map.put("coupon_code", item.getCouponCode());
            map.put("discount", item.getDiscount());
            map.put("redeemed", !item.isActive());
            couponData.add(map);
        }
        return couponData;
    }

    public void purchaseCoupon(Long userId, Long couponId, String couponCode) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Coupon coupon = couponRepository.findById(couponId)
                .orElseThrow(() -> new RuntimeException("Coupon not found"));

        if (user.getGreenBitePoints() < coupon.getCost()) {
            throw new RuntimeException("Not enough Green Bite Points");
        }

        user.setGreenBitePoints(user.getGreenBitePoints() - coupon.getCost());
        userRepository.save(user);

        if (couponCode == null || couponCode.trim().isEmpty()) {
            couponCode = "GB-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        }

        CouponManagement couponManagement = new CouponManagement(user, coupon, couponCode, coupon.getDiscount());
        couponManagementRepository.save(couponManagement);
    }

    public void redeemCoupon(String couponCode) {
        CouponManagement couponManagement = couponManagementRepository.findByCouponCode(couponCode)
                .orElseThrow(() -> new RuntimeException("Coupon not found!"));

        if (!couponManagement.isActive()) {
            throw new RuntimeException("Coupon already redeemed!");
        }

        couponManagement.setActive(false);
        couponManagementRepository.save(couponManagement);
    }
}
