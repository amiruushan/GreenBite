package com.greenbite.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "inventory")
@Getter
@Setter
public class Inventory {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "deal_id", nullable = false)
    private Deal deal;

    @Column(nullable = false)
    private String couponCode;

    @Column(nullable = false)
    private boolean isActive = true;

    @Column(nullable = false)
    private double discount; // ✅ Added discount field

    // Default constructor
    public Inventory() {
    }

    // Constructor for creating an inventory item
    public Inventory(User user, Deal deal, String couponCode, double discount) {
        this.user = user;
        this.deal = deal;
        this.couponCode = couponCode;
        this.discount = discount; // ✅ Initialize discount
    }
}