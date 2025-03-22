package com.greenbite.backend.controller;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.greenbite.backend.dto.FoodItemDTO;
import com.greenbite.backend.dto.FoodShopDTO;
import com.greenbite.backend.service.FoodItemService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@RestController
@RequestMapping("/api/food-items")
@CrossOrigin(origins = "*")
public class FoodItemController {

    private final FoodItemService foodItemService;
    private final ObjectMapper objectMapper;

    public FoodItemController(FoodItemService foodItemService, ObjectMapper objectMapper) {
        this.foodItemService = foodItemService;
        this.objectMapper = objectMapper;
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
        System.out.println("FOOD ITEMS : Lattitude: "+lat+" Longtitude: "+lon);
        List<FoodItemDTO> nearbyFoodItems = foodItemService.getFoodItemsNearby(lat, lon, radius);
        System.out.println(nearbyFoodItems);
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
    public ResponseEntity<FoodItemDTO> addFoodItem(
            @RequestPart("foodItem") String foodItemJson,
            @RequestPart(value = "foodImage", required = false) MultipartFile foodImage) throws IOException {

        // Convert the JSON string to a FoodItemDTO object
        FoodItemDTO foodItemDTO = objectMapper.readValue(foodItemJson, FoodItemDTO.class);

        // Save the food item
        FoodItemDTO savedFoodItem = foodItemService.addFoodItem(foodItemDTO, foodImage);
        return ResponseEntity.ok(savedFoodItem);
    }

    @DeleteMapping("/delete")
    public void deleteFoodItem(@RequestBody FoodItemDTO foodItemDTO){
        foodItemService.deleteFoodItem(foodItemDTO);
    }
}
