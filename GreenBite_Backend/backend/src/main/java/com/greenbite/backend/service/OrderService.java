package com.greenbite.backend.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.greenbite.backend.dto.FoodItemDTO;
import com.greenbite.backend.dto.OrderDTO;
import com.greenbite.backend.model.FoodItem;
import com.greenbite.backend.model.Order;
import com.greenbite.backend.repository.OrderRepository;
import com.greenbite.backend.repository.FoodItemRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final FoodItemRepository foodItemRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public OrderService(OrderRepository orderRepository, FoodItemRepository foodItemRepository) {
        this.orderRepository = orderRepository;
        this.foodItemRepository = foodItemRepository;
    }

    @Transactional
    public Order createOrder(OrderDTO orderDTO) {
        try {
            // Convert items to JSON (only saving id and quantity)
            String orderedItemsJson = objectMapper.writeValueAsString(
                    orderDTO.getItems().stream()
                            .map(itemDTO -> Map.of("id", itemDTO.getId(), "quantity", itemDTO.getQuantity()))
                            .collect(Collectors.toList())
            );

            // Reduce stock for each food item
            for (FoodItemDTO itemDTO : orderDTO.getItems()) {
                FoodItem foodItem = foodItemRepository.findById(itemDTO.getId())
                        .orElseThrow(() -> new RuntimeException("Food item not found"));
                foodItem.setQuantity(foodItem.getQuantity() - itemDTO.getQuantity());
                foodItemRepository.save(foodItem);
            }

            // Create and save order
            Order order = new Order(null, orderDTO.getCustomerId(), orderDTO.getShopId(),
                    orderDTO.getPaymentMethod(), "pending",
                    orderDTO.getTotalAmount(), orderDTO.getTotalCalories(),
                    orderedItemsJson);

            return orderRepository.save(order);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Error converting food items to JSON", e);
        }
    }

    public List<Order> getOrdersByShopId(Long shopId) {
        return orderRepository.findByShopId(shopId);
    }

    public List<Order> getOrdersByCustomerId(Long userId) {
        return orderRepository.findByCustomerId(userId);
    }

    public float getTotalCaloriesConsumed(Long customerId) {
        return (float) orderRepository.findByCustomerId(customerId)
                .stream()
                .mapToDouble(Order::getTotalCalories) // Use mapToDouble for floating-point sum
                .sum();
    }
}
