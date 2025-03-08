package com.greenbite.backend.service;


import com.greenbite.backend.dto.FoodShopDTO;
import com.greenbite.backend.model.FoodShop;
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
    public List<FoodShopDTO> getAllFoodShop() {
        return foodShopRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public FoodShopDTO getFoodShopById(Long id){
        FoodShop foodShop = foodShopRepository.findById(id)
                .orElseThrow(() ->new RuntimeException("Shop not found"));
        return convertToDTO(foodShop);
    }
    private FoodShopDTO convertToDTO(FoodShop foodShop){
        return new FoodShopDTO(
                foodShop.getId(),
                foodShop.getName(),
                foodShop.getAddress(),
                foodShop.getTele_number(),
                foodShop.getPhoto(),
                foodShop.getEmail(),
                foodShop.getBusinessName(),
                foodShop.getBusinessDescription()
        );
    }

    public FoodShopDTO updateFoodShop(FoodShopDTO foodShopDTO){
        FoodShop foodShop = foodShopRepository.findById(foodShopDTO.getId())
                .orElseThrow(() -> new RuntimeException("Working"));
        foodShop.setName(foodShopDTO.getName());
        foodShop.setAddress(foodShopDTO.getAddress());
        foodShop.setTele_number(foodShopDTO.getTele_number());
        foodShop.setPhoto(foodShopDTO.getPhoto());
        foodShop.setEmail(foodShopDTO.getEmail());
        foodShop.setBusinessName(foodShop.getBusinessName());
        foodShop.setBusinessDescription(foodShop.getBusinessDescription());

        foodShop = foodShopRepository.save(foodShop);
        return convertToDTO(foodShop);
    }


}

