package com.greenbite.backend.service;

import com.greenbite.backend.model.Order;
import com.greenbite.backend.repository.OrderRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ShopSalesService {

    private final OrderRepository orderRepository;

    public ShopSalesService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    public float calculateTotalSales(Long shopId, LocalDateTime startDate, LocalDateTime endDate) {
        List<Order> orders = orderRepository.findByShopIdAndOrderDateBetween(shopId, startDate, endDate);
        System.out.println(orders);
        return (float) orders.stream().mapToDouble(Order::getTotalAmount).sum();
    }
}