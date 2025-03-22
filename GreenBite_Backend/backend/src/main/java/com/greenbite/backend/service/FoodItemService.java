
package com.greenbite.backend.service;

import com.greenbite.backend.dto.FoodItemDTO;
import com.greenbite.backend.model.FoodItem;
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

    public FoodItemService(
            FoodItemRepository foodItemRepository,
            UserFavoriteRepository userFavoriteRepository,
            FileStorageService fileStorageService) {
        this.foodItemRepository = foodItemRepository;
        this.userFavoriteRepository = userFavoriteRepository;
        this.fileStorageService = fileStorageService;
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
        return new FoodItemDTO(
                foodItem.getId(),
                foodItem.getName(),
                foodItem.getDescription(),
                foodItem.getPrice(),
                foodItem.getQuantity(),
                foodItem.getShopId(),
                foodItem.getPhoto(),
                tagList,
                foodItem.getCategory(), // Convert category
                foodItem.getLatitude(), // Add latitude
                foodItem.getLongitude() // Add longitude
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
                foodItemDTO.getCategory(), // Convert category
                foodItemDTO.getLatitude(), // Add latitude
                foodItemDTO.getLongitude() // Add longitude
        );
    }

    public List<FoodItemDTO> getFoodItemsNearby(double lat, double lon, double radius) {
        List<FoodItem> allFoodItems = foodItemRepository.findAll();
        return allFoodItems.stream()
                .filter(item -> {
                    double distance = calculateDistance(lat, lon, item.getLatitude(), item.getLongitude());
                    return distance <= radius;
                })
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return EARTH_RADIUS * c;
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
}