package com.greenbite.backend.service;

import com.greenbite.backend.model.User;
import com.greenbite.backend.model.FoodItem;
import com.greenbite.backend.model.UserFavorite;
import com.greenbite.backend.repository.UserFavoriteRepository;
import com.greenbite.backend.repository.UserRepository;
import com.greenbite.backend.repository.FoodItemRepository;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class UserFavoriteService {
    private final UserFavoriteRepository userFavoriteRepository;
    private final UserRepository userRepository;
    private final FoodItemRepository foodItemRepository;

    public UserFavoriteService(UserFavoriteRepository userFavoriteRepository, UserRepository userRepository, FoodItemRepository foodItemRepository) {
        this.userFavoriteRepository = userFavoriteRepository;
        this.userRepository = userRepository;
        this.foodItemRepository = foodItemRepository;
    }

    // Add a favorite food item for a user
    public String addFavorite(Long userId, Long foodItemId) {
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
        FoodItem foodItem = foodItemRepository.findById(foodItemId).orElseThrow(() -> new RuntimeException("Food item not found"));

        if (userFavoriteRepository.findByUserAndFoodItem(user, foodItem).isPresent()) {
            return "Food item already in favorites";
        }

        UserFavorite userFavorite = new UserFavorite();
        userFavorite.setUser(user);
        userFavorite.setFoodItem(foodItem);
        userFavoriteRepository.save(userFavorite);
        return "Food item added to favorites";
    }

    // Get a user's favorite food items
    public List<FoodItem> getUserFavorites(Long userId) {
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
        return userFavoriteRepository.findByUser(user)
                .stream()
                .map(UserFavorite::getFoodItem)
                .collect(Collectors.toList());
    }

    // Remove a favorite food item for a user
    @Transactional
    public String removeFavorite(Long userId, Long foodItemId) {
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
        FoodItem foodItem = foodItemRepository.findById(foodItemId).orElseThrow(() -> new RuntimeException("Food item not found"));

        Optional<UserFavorite> favorite = userFavoriteRepository.findByUserAndFoodItem(user, foodItem);
        if (favorite.isPresent()) {
            userFavoriteRepository.deleteByUserAndFoodItem(user, foodItem);
            return "Food item removed from favorites";
        } else {
            return "Food item not found in favorites";
        }
    }
}

