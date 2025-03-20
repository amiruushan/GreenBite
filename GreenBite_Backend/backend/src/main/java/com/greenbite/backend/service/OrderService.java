package com.greenbite.backend.service;

import com.greenbite.backend.dto.OrderDTO;
import com.greenbite.backend.model.FoodItem;
import com.greenbite.backend.model.Order;
import com.greenbite.backend.repository.OrderRepository;
import com.greenbite.backend.repository.FoodItemRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    @Transactional
    public Order createOrder(OrderDTO orderDTO) {
        List<FoodItem> foodItems = orderDTO.getItems().stream()
                .map(itemDTO -> {
                    FoodItem foodItem = foodItemRepository.findById(itemDTO.getId())
                            .orElseThrow(() -> new RuntimeException("Food item not found"));
                    // Reduce stock
                    foodItem.setQuantity(foodItem.getQuantity() - itemDTO.getQuantity());
                    foodItemRepository.save(foodItem);

                    return foodItem;
                })
                .collect(Collectors.toList());

        // Create and save the order
        Order order = new Order(null, orderDTO.getCustomerId(), orderDTO.getShopId(),orderDTO.getPaymentMethod(), "pending", foodItems);
        return orderRepository.save(order);
    }
    public List<Order> getOrdersByShopId(Long shopId) {
        return orderRepository.findByShopId(shopId);
    }
    public List<Order> getOrdersByCustomerId(Long userId) {
        return orderRepository.findByCustomerId(userId);
    }

}
