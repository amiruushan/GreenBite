package com.greenbite.backend.service;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.greenbite.backend.dto.FoodShopDTO;
import com.greenbite.backend.dto.UserDTO;
import com.greenbite.backend.model.FoodShop;
import com.greenbite.backend.model.User;
import com.greenbite.backend.repository.FoodShopRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class FoodShopService {
    @Autowired
    private FoodShopRepository foodShopRepository;

    @Autowired
    private FileStorageService fileStorageService;


    public FoodShop saveFoodShop(FoodShop foodShop) {
        return foodShopRepository.save(foodShop);
    }

    public List<FoodShopDTO> getAllFoodShops() {
        List<FoodShop> foodShops = foodShopRepository.findAll();
        return foodShops.stream()
                .map(shop -> new FoodShopDTO(shop.getId(), shop.getName(), shop.getPhoto()))
                .collect(Collectors.toList());
    }

    public List<FoodShopDTO> getAllFoodShopsAdmin() {
        List<FoodShop> foodShops = foodShopRepository.findAll();
        return foodShops.stream()
                .map(shop -> new FoodShopDTO(
                        shop.getId(),
                        shop.getName(),
                        shop.getPhoto(),
                        shop.getAddress(),
                        shop.getPhoneNumber(),
                        shop.getLatitude(),
                        shop.getLongitude()
                ))
                .collect(Collectors.toList());
    }

    public FoodShopDTO getFoodShopById(Long id) {
        FoodShop foodShop = foodShopRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shop not found"));
        return convertToDTO(foodShop);
    }
    private FoodShopDTO convertToDTO(FoodShop foodShop) {
        return new FoodShopDTO(
                foodShop.getId(),
                foodShop.getName(),
                foodShop.getPhoto(),
                foodShop.getAddress(),
                foodShop.getPhoneNumber(),  // or getPhoneNumber() if you rename it
                foodShop.getLatitude(),
                foodShop.getLongitude(),
                foodShop.getLicenseExpirationDate(),
                foodShop.getBusinessDescription()
        );
    }

    public void deleteFoodShopById(Long foodShopId) {
        if (foodShopRepository.existsById(foodShopId)) {
            foodShopRepository.deleteById(foodShopId);
        } else {
            throw new RuntimeException("food shop not found with ID: " + foodShopId);
        }
    }

    public FoodShop updateFoodShop(Long id, String shopJson, MultipartFile photo) throws IOException {
        ObjectMapper objectMapper = new ObjectMapper();
        FoodShop updatedShop = objectMapper.readValue(shopJson, FoodShop.class);

        return foodShopRepository.findById(id)
                .map(existingShop -> {
                    existingShop.setName(updatedShop.getName());
                    existingShop.setAddress(updatedShop.getAddress());
                    existingShop.setPhoneNumber(updatedShop.getPhoneNumber());
                    existingShop.setEmail(updatedShop.getEmail());
                    existingShop.setBusinessDescription(updatedShop.getBusinessDescription());

                    // Handle photo upload
                    if (photo != null && !photo.isEmpty()) {
                        // Delete the old photo if it exists
                        if (existingShop.getPhoto() != null) {
                            try {
                                fileStorageService.deleteFile(existingShop.getPhoto());
                            } catch (IOException e) {
                                throw new RuntimeException(e);
                            }
                        }

                        // Save the new photo to GCS
                        String fileUrl = null;
                        try {
                            fileUrl = fileStorageService.saveFile(photo);
                        } catch (IOException e) {
                            throw new RuntimeException(e);
                        }
                        existingShop.setPhoto(fileUrl); // Save the GCS URL in the database
                    }

                    return foodShopRepository.save(existingShop);
                })
                .orElseThrow(() -> new RuntimeException("Shop not found"));
    }

    // Earth's radius in kilometers
    private static final double EARTH_RADIUS = 6371;

    public List<FoodShop> findShopsNearby(double lat, double lon, double radius) {
        List<FoodShop> allShops = foodShopRepository.findAll();

        return allShops.stream()
                .filter(shop -> calculateDistance(lat, lon, shop.getLatitude(), shop.getLongitude()) <= radius)
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

    public List<FoodShopDTO> getExpiredLicenseShops() {
        LocalDate today = LocalDate.now();
        List<FoodShop> expiredShops = foodShopRepository.findAll().stream()
                .filter(shop -> shop.getLicenseExpirationDate().isBefore(today))
                .collect(Collectors.toList());

        return expiredShops.stream()
                .map(shop -> new FoodShopDTO(
                        shop.getId(),
                        shop.getName(),
                        shop.getPhoto(),
                        shop.getAddress(),
                        shop.getPhoneNumber(),
                        shop.getLatitude(),
                        shop.getLongitude(),
                        shop.getLicenseExpirationDate()
                ))
                .collect(Collectors.toList());
    }

    public List<FoodShopDTO> getShopsWithNearExpiration() {
        LocalDate today = LocalDate.now();
        LocalDate twoWeeksLater = today.plusWeeks(2);

        List<FoodShop> nearExpiryShops = foodShopRepository.findAll().stream()
                .filter(shop ->
                        shop.getLicenseExpirationDate() != null &&
                                !shop.getLicenseExpirationDate().isBefore(today) &&
                                shop.getLicenseExpirationDate().isBefore(twoWeeksLater)
                )
                .collect(Collectors.toList());

        return nearExpiryShops.stream()
                .map(shop -> new FoodShopDTO(
                        shop.getId(),
                        shop.getName(),
                        shop.getPhoto(),
                        shop.getAddress(),
                        shop.getPhoneNumber(),
                        shop.getLatitude(),
                        shop.getLongitude(),
                        shop.getLicenseExpirationDate()
                ))
                .collect(Collectors.toList());
    }

    public LocalDate getFoodShopExpirationDate(Long shopId) {
        return foodShopRepository.findById(shopId)
                .map(FoodShop::getLicenseExpirationDate)
                .orElseThrow(() -> new RuntimeException("Shop not found with ID: " + shopId));
    }

}
