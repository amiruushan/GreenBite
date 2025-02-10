package com.greenbite.backend.repository;

import com.greenbite.backend.model.FoodShop;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FoodShopRepository extends JpaRepository<FoodShop, Long> {
}
