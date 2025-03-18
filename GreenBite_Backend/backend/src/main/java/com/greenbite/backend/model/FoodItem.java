package com.greenbite.backend.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "food_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class FoodItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String description;
    private Double price;
    private Integer quantity;
    private String photo;

    private String tags; // Store tags as a comma-separated string

    private Long shopId; // Use shopId instead of mapping FoodShop to simplify DTO conversion

    private String category; // New field for category

    @Column(nullable = false)
    private double latitude; // Add latitude field

    @Column(nullable = false)
    private double longitude; // Add longitude field
}