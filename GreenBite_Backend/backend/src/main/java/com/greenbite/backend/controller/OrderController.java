package com.greenbite.backend.controller;

import com.greenbite.backend.dto.OrderDTO;
import com.greenbite.backend.model.Order;
import com.greenbite.backend.service.OrderService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @PostMapping("/confirm")
    public ResponseEntity<Order> confirmOrder(@RequestBody OrderDTO orderDTO) {
        Order order = orderService.createOrder(orderDTO);
        return ResponseEntity.ok(order);
    }

    @GetMapping("/{orderId}/shop/{shopId}")
    public ResponseEntity<List<Order>> getOrdersByOrderIdAndShopId(
            @PathVariable Long orderId, @PathVariable Long shopId) {
        List<Order> orders = orderService.getOrdersByOrderIdAndShopId(orderId, shopId);
        return ResponseEntity.ok(orders);
    }
}
