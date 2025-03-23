
package com.greenbite.backend.service;

import com.greenbite.backend.dto.FoodItemDTO;
import com.greenbite.backend.dto.FoodShopDTO;
import com.greenbite.backend.model.FoodItem;
import com.greenbite.backend.model.FoodShop;
import com.greenbite.backend.model.UserFavorite;
import com.greenbite.backend.repository.FoodItemRepository;
import com.greenbite.backend.repository.UserFavoriteRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class FoodItemService {

    private static final double EARTH_RADIUS = 6371; // Earth's radius in km
    private final FoodItemRepository foodItemRepository;
    private final UserFavoriteRepository userFavoriteRepository;
    private final FileStorageService fileStorageService;
    private final FoodShopService foodShopService;

    public FoodItemService(
            FoodItemRepository foodItemRepository,
            UserFavoriteRepository userFavoriteRepository,
            FileStorageService fileStorageService,FoodShopService foodShopService) {
        this.foodItemRepository = foodItemRepository;
        this.userFavoriteRepository = userFavoriteRepository;
        this.fileStorageService = fileStorageService;
        this.foodShopService=foodShopService;
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

    public FoodItemDTO addFoodItem(FoodItemDTO foodItemDTO, MultipartFile foodImage) throws IOException {
        // Convert DTO to Entity
        FoodItem foodItem = convertToEntity(foodItemDTO);

        // Handle food image upload
        if (foodImage != null && !foodImage.isEmpty()) {
            String fileUrl = fileStorageService.saveFile(foodImage);
            foodItem.setPhoto(fileUrl); // Save the uploaded image URL
        }

        // Save food item to database
        foodItem = foodItemRepository.save(foodItem);
        return convertToDTO(foodItem);
    }

    private FoodItemDTO convertToDTO(FoodItem foodItem) {
        List<String> tagList = Arrays.asList(foodItem.getTags().split(",")); // Convert comma-separated string to list

        // Fetch food shop name
        FoodShopDTO shop = foodShopService.getFoodShopById(foodItem.getShopId());

        return new FoodItemDTO(
                foodItem.getId(),
                foodItem.getName(),
                shop != null ? shop.getName() : null,
                foodItem.getDescription(),
                foodItem.getPrice(),
                foodItem.getQuantity(),
                foodItem.getShopId(),
                foodItem.getPhoto(),
                tagList,
                foodItem.getCategory()
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
                foodItemDTO.getCategory()
        );
    }

    public List<FoodItemDTO> getFoodItemsNearby(double lat, double lon, double radius) {
        List<FoodShop> nearbyShops = foodShopService.findShopsNearby(lat, lon, radius);

        List<FoodItem> foodItems = nearbyShops.stream()
                .flatMap(shop -> foodItemRepository.findByShopId(shop.getId()).stream())
                .collect(Collectors.toList());

        return foodItems.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }


    public void deleteFoodItem(Long id) {
        // Find the food item by ID
        FoodItem foodItem = foodItemRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Food item not found"));

        // Delete all related UserFavorite entries
        List<UserFavorite> userFavorites = userFavoriteRepository.findByFoodItemId(id);
        userFavoriteRepository.deleteAll(userFavorites);

        // Delete the food item
        foodItemRepository.delete(foodItem);
    }
    public FoodItemDTO updateFoodItem(FoodItemDTO foodItemDTO) {
        FoodItem existingFoodItem = foodItemRepository.findById(foodItemDTO.getId())
                .orElseThrow(() -> new RuntimeException("Food item not found"));

        // Update fields from DTO
        existingFoodItem.setName(foodItemDTO.getName());
        existingFoodItem.setDescription(foodItemDTO.getDescription());
        existingFoodItem.setPrice(foodItemDTO.getPrice());
        existingFoodItem.setQuantity(foodItemDTO.getQuantity());
        existingFoodItem.setCategory(foodItemDTO.getCategory());

        // Convert tags list to a comma-separated string
        String tags = String.join(",", foodItemDTO.getTags());
        existingFoodItem.setTags(tags);

        // Save updated entity
        existingFoodItem = foodItemRepository.save(existingFoodItem);
        return convertToDTO(existingFoodItem);
    }

}