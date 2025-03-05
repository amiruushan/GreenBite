package com.greenbite.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "coupons")
@Getter
@Setter
public class Coupon {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String icon;

    @Column(nullable = false)
    private String color;

    @Column(nullable = false)
    private int cost;

    @Column(nullable = false)
    private double discount;

    public Coupon() {
    }

    public Coupon(String title, String icon, String color, int cost, double discount) {
        this.title = title;
        this.icon = icon;
        this.color = color;
        this.cost = cost;
        this.discount = discount;
    }
}
