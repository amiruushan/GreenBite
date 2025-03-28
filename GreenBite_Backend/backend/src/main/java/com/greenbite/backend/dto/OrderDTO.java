package com.greenbite.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class OrderDTO {

    private Long customerId;
    private Long shopId;
    private String paymentMethod;
    private List<FoodItemDTO> items;
    private float totalAmount;
    private float totalCalories;
    private LocalDateTime orderDate;
    private double latitude; // Add latitude
    private double longitude; // Add longitude
}
