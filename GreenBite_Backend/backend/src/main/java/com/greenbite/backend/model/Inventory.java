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
    private String dealName; // ✅ Add this field

    @Column(nullable = false)
    private String couponCode;

    @Column(nullable = false)
    private boolean isActive = true;

    // ✅ Constructor to include dealName
    public Inventory(User user, Deal deal, String couponCode) {
        this.user = user;
        this.deal = deal;
        this.dealName = deal.getTitle(); // ✅ Set deal name from the deal entity
        this.couponCode = couponCode;
    }

    public Inventory() {
    }
}
