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
}

