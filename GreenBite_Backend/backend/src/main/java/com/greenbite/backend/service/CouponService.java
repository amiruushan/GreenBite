package com.greenbite.backend.service;

import com.greenbite.backend.model.Coupon;
import com.greenbite.backend.repository.CouponRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CouponService {
    private final CouponRepository couponRepository;

    public CouponService(CouponRepository couponRepository) {
        this.couponRepository = couponRepository;
    }

    public List<Coupon> getAllCoupons() {
        return (List<Coupon>) couponRepository.findAll();
    }

    public void createCoupon(Coupon coupon) {
        couponRepository.save(coupon);
    }

    // Deleting a coupon by ID
    public void deleteCouponById(Long couponId) {
        if (couponRepository.existsById(couponId)) {
            couponRepository.deleteById(couponId);
        } else {
            throw new RuntimeException("Coupon not found with ID: " + couponId);
        }
    }
}

