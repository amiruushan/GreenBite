package com.greenbite.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "food_shops")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class FoodShop {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String address;

    @Column(nullable = false, length = 20)
    private String tele_number;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String businessName;

    @Column(columnDefinition = "TEXT")
    private String businessDescription;


    private String photo;  // Store image URL
}
