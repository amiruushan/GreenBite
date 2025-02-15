package com.greenbite.backend.service;

import com.greenbite.backend.dto.FoodItemDTO;
import com.greenbite.backend.dto.OrderDTO;
import com.greenbite.backend.model.FoodItem;
import com.greenbite.backend.model.Order;
import com.greenbite.backend.repository.OrderRepository;
import com.greenbite.backend.repository.FoodItemRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final FoodItemRepository foodItemRepository;

    public OrderService(OrderRepository orderRepository, FoodItemRepository foodItemRepository) {
        this.orderRepository = orderRepository;
        this.foodItemRepository = foodItemRepository;
    }

    public Order createOrder(OrderDTO orderDTO) {
        // Convert the FoodItemDTO to FoodItem entities
        List<FoodItem> foodItems = orderDTO.getItems().stream()
                .map(itemDTO -> foodItemRepository.findById(itemDTO.getId()).orElseThrow(() -> new RuntimeException("Food item not found")))
                .collect(Collectors.toList());

        // Create and save the order
        Order order = new Order(null, orderDTO.getCustomerId(), orderDTO.getPaymentMethod(), "pending", foodItems);
        return orderRepository.save(order);
    }
}
