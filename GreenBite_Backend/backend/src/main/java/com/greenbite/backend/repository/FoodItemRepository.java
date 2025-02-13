package com.greenbite.backend.repository;

import com.greenbite.backend.model.FoodItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FoodItemRepository extends JpaRepository<FoodItem, Long> {

    List<FoodItem> findByShopId(Long shopId);

    List<FoodItem> findByCategory(String category); // New method to filter by category
}


//@Query("SELECT f FROM FoodItem f WHERE LOWER(f.tags) LIKE LOWER(CONCAT('%', :tag, '%'))")
//List<FoodItem> findByTag(String tag);