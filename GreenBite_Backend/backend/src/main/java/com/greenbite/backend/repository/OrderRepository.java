package com.greenbite.backend.repository;

import com.greenbite.backend.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByShopId(Long shopId);
    List<Order> findByCustomerId(Long userId);

}
