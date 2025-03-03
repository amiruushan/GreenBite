package com.greenbite.backend.repository;

import com.greenbite.backend.model.UserFavorite;
import com.greenbite.backend.model.User;
import com.greenbite.backend.model.FoodItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserFavoriteRepository extends JpaRepository<UserFavorite, Long> {
    List<UserFavorite> findByUser(User user);
    Optional<UserFavorite> findByUserAndFoodItem(User user, FoodItem foodItem);
    void deleteByUserAndFoodItem(User user, FoodItem foodItem);
}
