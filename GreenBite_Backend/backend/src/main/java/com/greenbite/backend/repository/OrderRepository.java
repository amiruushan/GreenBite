package com.greenbite.backend.repository;

import com.greenbite.backend.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByShopId(Long shopId);
    List<Order> findByCustomerId(Long userId);
    List<Order> findByShopIdAndOrderDateBetween(Long shopId, LocalDateTime startDate, LocalDateTime endDate);
    List<Order> findByOrderDateBetween(LocalDateTime startDate, LocalDateTime endDate);
    Order findTopByOrderByOrderDateDesc();
}
