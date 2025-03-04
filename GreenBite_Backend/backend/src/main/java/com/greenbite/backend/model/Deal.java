package com.greenbite.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "deals")
@Getter
@Setter
public class Deal {
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
    private double discount; // ✅ Added discount field

    // Default constructor
    public Deal() {
    }

    // Constructor for creating a deal
    public Deal(String title, String icon, String color, int cost, double discount) {
        this.title = title;
        this.icon = icon;
        this.color = color;
        this.cost = cost;
        this.discount = discount; // ✅ Initialize discount
    }
}