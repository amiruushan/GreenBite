package com.greenbite.backend.controller;

import com.greenbite.backend.dto.OrderDTO;
import com.greenbite.backend.model.Order;
import com.greenbite.backend.service.OrderService;
import org.aspectj.weaver.ast.Or;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

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
        System.out.println("Order DTO: "+orderDTO);
        Order order = orderService.createOrder(orderDTO);
        return ResponseEntity.ok(order);
    }
    @GetMapping("/latest")
    public ResponseEntity<Map<String, Object>> getLatestOrder() {
        Order latestOrder = orderService.getLatestOrder();
        if (latestOrder == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "No orders found"));
        }

        Map<String, Object> response = Map.of(
                "orderId", String.valueOf(latestOrder.getId()), // Ensure it's a string
                "orderTime", latestOrder.getOrderDate().toString(),
                "totalAmount", latestOrder.getTotalAmount(),
                "status", latestOrder.getStatus(),
                "latitude", latestOrder.getLatitude(),
                "longitude", latestOrder.getLongitude(),
                "paymentMethod", latestOrder.getPaymentMethod()
        );

        return ResponseEntity.ok(response);
    }


    @GetMapping("/shop_order/{shopId}")
    public ResponseEntity<List<Order>> getOrdersByShopId(@PathVariable Long shopId) {
        List<Order> orders = orderService.getOrdersByShopId(shopId);
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/user_orders/{userId}")
    public ResponseEntity<List<Order>> getOrdersByUserId(@PathVariable Long userId) {
        List<Order> orders = orderService.getOrdersByCustomerId(userId);
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/total_calories/{userId}")
    public ResponseEntity<Float> getTotalCaloriesConsumed(@PathVariable Long userId) {
        float totalCalories = orderService.getTotalCaloriesConsumed(userId);
        return ResponseEntity.ok(totalCalories);
    }

    @PutMapping("/{orderId}/status")
    public ResponseEntity<Order> updateOrderStatus(@PathVariable Long orderId, @RequestParam String status) {
        Order updatedOrder = orderService.updateOrderStatus(orderId, status);
        return ResponseEntity.ok(updatedOrder);
    }

}
