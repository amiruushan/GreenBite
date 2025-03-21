package com.greenbite.backend.controller;
import com.greenbite.backend.dto.FoodItemDTO;
import com.greenbite.backend.dto.FoodShopDTO;
import com.greenbite.backend.service.FoodItemService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.List;

@RestController
@RequestMapping("/api/food-items")
@CrossOrigin(origins = "*")
public class FoodItemController {

    private final FoodItemService foodItemService;

    public FoodItemController(FoodItemService foodItemService) {
        this.foodItemService = foodItemService;
    }

    @GetMapping("/get")
    public List<FoodItemDTO> getAllFoodItems() {
        return foodItemService.getAllFoodItems();
    }

    @GetMapping("/shop/{shopId}")
    public List<FoodItemDTO> getFoodItemsByShop(@PathVariable Long shopId) {
        return foodItemService.getFoodItemsByShop(shopId);
    }

    @GetMapping("/nearby/{lat}/{lon}/{radius}")
    public List<FoodItemDTO> getFoodItemsNearby(
            @PathVariable double lat,
            @PathVariable double lon,
            @PathVariable double radius) {
        radius=200;
        List<FoodItemDTO> nearbyFoodItems = foodItemService.getFoodItemsNearby(lat, lon, radius);
        return nearbyFoodItems;
    }



//    @GetMapping("/tags/{tags}")
//    public List<FoodItemDTO> getFoodItemsByTags(@PathVariable String tags) {
//        List<String> tagList = Arrays.asList(tags.split(","));
//        return foodItemService.getFoodItemsByTags(tagList);
//    }

    @GetMapping("/category/{category}")
    public List<FoodItemDTO> getFoodItemsByCategory(@PathVariable String category) {
        return foodItemService.getFoodItemsByCategory(category);
    }

    @PostMapping
    public FoodItemDTO addFoodItem(@RequestBody FoodItemDTO foodItemDTO) {
        return foodItemService.addFoodItem(foodItemDTO);
    }

    @DeleteMapping("/delete")
    public void deleteFoodItem(@RequestBody FoodItemDTO foodItemDTO){
        foodItemService.deleteFoodItem(foodItemDTO);
    }
}
