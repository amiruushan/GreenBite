package com.greenbite.backend.model;

import jakarta.persistence.*;
import lombok.*;

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
    private String paymentMethod;
    private String status = "pending"; // Default status is "pending"

    @ManyToMany
    @JoinTable(
            name = "order_food_items",
            joinColumns = @JoinColumn(name = "order_id"),
            inverseJoinColumns = @JoinColumn(name = "food_item_id")
    )
    private List<FoodItem> items; // List of FoodItems in the order
}
