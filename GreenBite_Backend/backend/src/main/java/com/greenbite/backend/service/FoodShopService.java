package com.greenbite.backend.service;


import com.greenbite.backend.dto.FoodShopDTO;
import com.greenbite.backend.dto.UserDTO;
import com.greenbite.backend.model.FoodShop;
import com.greenbite.backend.model.User;
import com.greenbite.backend.repository.FoodShopRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class FoodShopService {
    @Autowired
    private FoodShopRepository foodShopRepository;

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
                foodShop.getLongitude()
        );
    }

    public void deleteFoodShopById(Long foodShopId) {
        if (foodShopRepository.existsById(foodShopId)) {
            foodShopRepository.deleteById(foodShopId);
        } else {
            throw new RuntimeException("food shop not found with ID: " + foodShopId);
        }
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

}