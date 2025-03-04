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
    public List<FoodShopDTO> getAllFoodShops() {
        List<FoodShop> foodShops = foodShopRepository.findAll();
        return foodShops.stream()
                .map(shop -> new FoodShopDTO(shop.getId(), shop.getName(), shop.getPhoto(),shop.getEmail(),shop.getBusinessName(),shop.getBusinessDescription()))
                .collect(Collectors.toList());
    }

    public FoodShopDTO getFoodShopById(Long id){
        FoodShop foodShop = foodShopRepository.findById(id)
                .orElseThrow(() ->new RuntimeException("Shop not found"));
        return convertToDTO(foodShop);
    }
    private FoodShopDTO convertToDTO(FoodShop foodShop){
        return new FoodShopDTO(foodShop.getId(),foodShop.getName(),foodShop.getPhoto(),foodShop.getEmail(),foodShop.getBusinessName(), foodShop.getBusinessDescription()
        );
    }


}

