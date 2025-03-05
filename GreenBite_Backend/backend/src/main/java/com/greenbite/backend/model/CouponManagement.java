package com.greenbite.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "coupon_management")
@Getter
@Setter
public class CouponManagement {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "coupon_id", nullable = false)
    private Coupon coupon;

    @Column(nullable = false)
    private String couponCode;

    @Column(nullable = false)
    private boolean isActive = true;

    @Column(nullable = false)
    private double discount;

    public CouponManagement() {
    }

    public CouponManagement(User user, Coupon coupon, String couponCode, double discount) {
        this.user = user;
        this.coupon = coupon;
        this.couponCode = couponCode;
        this.discount = discount;
    }
}
