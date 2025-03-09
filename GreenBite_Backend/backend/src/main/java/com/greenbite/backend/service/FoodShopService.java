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
                .map(shop -> new FoodShopDTO(shop.getId(), shop.getName(), shop.getAddress(),shop.getPhoto(), shop.getTele_number(),shop.getEmail(),shop.getBusinessName(),shop.getBusinessDescription()))
                .collect(Collectors.toList());
    }

    public FoodShopDTO getFoodShopById(Long id){
        FoodShop foodShop = foodShopRepository.findById(id)
                .orElseThrow(() ->new RuntimeException("Shop not found"));
        return convertToDTO(foodShop);
    }
    private FoodShopDTO convertToDTO(FoodShop foodShop){
        return new FoodShopDTO(foodShop.getId(),foodShop.getName(),foodShop.getPhoto()
        );
    }

    public void deleteFoodShopById(Long foodShopId) {
        if (foodShopRepository.existsById(foodShopId)) {
            foodShopRepository.deleteById(foodShopId);
        } else {
            throw new RuntimeException("food shop not found with ID: " + foodShopId);
        }
    }

    public FoodShop updateFoodShop(Long id, FoodShop updatedShop) {
        return foodShopRepository.findById(id)
                .map(existingShop -> {
                    existingShop.setName(updatedShop.getName());
                    existingShop.setAddress(updatedShop.getAddress());
                    existingShop.setTele_number(updatedShop.getTele_number());
                    existingShop.setEmail(updatedShop.getEmail());
                    existingShop.setBusinessName(updatedShop.getBusinessName());
                    existingShop.setBusinessDescription(updatedShop.getBusinessDescription());
                    existingShop.setPhoto(updatedShop.getPhoto());
                    return foodShopRepository.save(existingShop);
                })
                .orElseThrow(() -> new RuntimeException("Shop not found"));
    }



}