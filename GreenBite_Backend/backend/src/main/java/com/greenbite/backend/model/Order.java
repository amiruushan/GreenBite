package com.greenbite.backend.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "orders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long customerId; // Foreign key to the Customer entity
    private Long shopId;
    private String paymentMethod;
    private String status = "pending"; // Default status is "pending"
    private float totalAmount;
    private float totalCalories;
    private LocalDateTime orderDate;
    private double latitude; // Add latitude
    private double longitude; // Add longitude

    @Column(columnDefinition = "TEXT") // Store JSON as text
    private String orderedItemsJson;
}
