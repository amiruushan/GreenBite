package com.greenbite.backend.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.greenbite.backend.model.Order;
import com.greenbite.backend.repository.FoodItemRepository;
import com.greenbite.backend.repository.OrderRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ShopSalesService {

    private final OrderRepository orderRepository;
    private final ObjectMapper objectMapper;

    public ShopSalesService(OrderRepository orderRepository, ObjectMapper objectMapper) {
        this.orderRepository = orderRepository;
        this.objectMapper = objectMapper;
    }

    public float calculateTotalSales(Long shopId, LocalDateTime startDate, LocalDateTime endDate) {
        List<Order> orders = orderRepository.findByShopIdAndOrderDateBetween(shopId, startDate, endDate);
        System.out.println(orders);
        return (float) orders.stream().mapToDouble(Order::getTotalAmount).sum();
    }

    public float calculateTotalSalesForAllShops(LocalDateTime startDate, LocalDateTime endDate) {
        List<Order> orders = orderRepository.findByOrderDateBetween(startDate, endDate);
        System.out.println(orders);
        return (float) orders.stream().mapToDouble(Order::getTotalAmount).sum();
    }
    public Map<Long, Double> getTotalSalesByShop(Long shopId, LocalDateTime startDate, LocalDateTime endDate) {
        List<Order> orders = orderRepository.findByShopIdAndOrderDateBetween(shopId, startDate, endDate);
        Map<Long, Double> itemSalesRevenue = new HashMap<>();

        for (Order order : orders) {
            try {
                // Deserialize orderedItemsJson
                List<Map<String, Object>> orderedItems = objectMapper.readValue(
                        order.getOrderedItemsJson(),
                        new TypeReference<List<Map<String, Object>>>() {}
                );

                for (Map<String, Object> item : orderedItems) {
                    Long itemId = ((Number) item.get("id")).longValue();
                    Integer quantity = ((Number) item.get("quantity")).intValue();
                    Double price = ((Number) item.get("price")).doubleValue();

                    // Calculate total sales for the item
                    double totalSales = quantity * price;
                    itemSalesRevenue.put(itemId, itemSalesRevenue.getOrDefault(itemId, 0.0) + totalSales);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return itemSalesRevenue; // Returns {itemId → totalSales}
    }

}