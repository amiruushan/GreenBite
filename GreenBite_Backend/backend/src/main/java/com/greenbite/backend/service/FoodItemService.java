package com.greenbite.backend.service;
import com.greenbite.backend.dto.FoodItemDTO;
import com.greenbite.backend.model.FoodItem;
import com.greenbite.backend.repository.FoodItemRepository;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class FoodItemService {

    private final FoodItemRepository foodItemRepository;

    public FoodItemService(FoodItemRepository foodItemRepository) {
        this.foodItemRepository = foodItemRepository;
    }

    public List<FoodItemDTO> getAllFoodItems() {
        return foodItemRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<FoodItemDTO> getFoodItemsByShop(Long shopId) {
        return foodItemRepository.findByShopId(shopId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<FoodItemDTO> getFoodItemsByCategory(String category) {
        return foodItemRepository.findByCategory(category).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public FoodItemDTO addFoodItem(FoodItemDTO foodItemDTO) {
        FoodItem foodItem = convertToEntity(foodItemDTO);
        return convertToDTO(foodItemRepository.save(foodItem));
    }

    private FoodItemDTO convertToDTO(FoodItem foodItem) {
        List<String> tagList = Arrays.asList(foodItem.getTags().split(",")); // Convert comma-separated string to list
        return new FoodItemDTO(
                foodItem.getId(),
                foodItem.getName(),
                foodItem.getDescription(),
                foodItem.getPrice(),
                foodItem.getQuantity(),
                foodItem.getShopId(),
                foodItem.getPhoto(),
                tagList,
                foodItem.getCategory() // Convert category
        );
    }

    private FoodItem convertToEntity(FoodItemDTO foodItemDTO) {
        String tags = String.join(",", foodItemDTO.getTags()); // Convert list to comma-separated string
        return new FoodItem(
                foodItemDTO.getId(),
                foodItemDTO.getName(),
                foodItemDTO.getDescription(),
                foodItemDTO.getPrice(),
                foodItemDTO.getQuantity(),
                foodItemDTO.getPhoto(),
                tags,
                foodItemDTO.getShopId(),
                foodItemDTO.getCategory() // Convert category
        );
    }

    public void deleteFoodItem(FoodItemDTO foodItemDTO) {
        Long id = foodItemDTO.getId();
        if (foodItemRepository.existsById(id)) {
            foodItemRepository.deleteById(id);
        } else {
            throw new RuntimeException("Food item not found");
        }
    }


}
