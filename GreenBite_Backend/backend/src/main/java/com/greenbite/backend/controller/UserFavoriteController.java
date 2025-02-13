package com.greenbite.backend.controller;

import com.greenbite.backend.model.FoodItem;
import com.greenbite.backend.service.UserFavoriteService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/favorites")
public class UserFavoriteController {
    private final UserFavoriteService userFavoriteService;

    public UserFavoriteController(UserFavoriteService userFavoriteService) {
        this.userFavoriteService = userFavoriteService;
    }

    @PostMapping("/add")
    public String addFavorite(@RequestParam Long userId, @RequestParam Long foodItemId) {
        System.out.println("Fav add working");
        return userFavoriteService.addFavorite(userId, foodItemId);
    }

    @GetMapping("/user/{userId}")
    public List<FoodItem> getUserFavorites(@PathVariable Long userId) {
        System.out.println("Fav get working");
        System.out.println("User ID = "+userId);
        return userFavoriteService.getUserFavorites(userId);
    }

    @DeleteMapping("/remove/{userId}/{foodItemId}")
    public String removeFavorite(@PathVariable Long userId, @PathVariable Long foodItemId) {
        System.out.println("Fav remove working");
        return userFavoriteService.removeFavorite(userId, foodItemId);
    }

}
