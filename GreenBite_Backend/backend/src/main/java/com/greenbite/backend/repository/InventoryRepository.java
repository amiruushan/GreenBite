package com.greenbite.backend.repository;

import com.greenbite.backend.model.Inventory;
import com.greenbite.backend.model.User;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface InventoryRepository extends CrudRepository<Inventory, Long> {
    List<Inventory> findByUser(User user);
    Optional<Inventory> findByCouponCode(String couponCode);
}