package com.greenbite.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@AllArgsConstructor
@Getter
@Setter
public class FoodShopDTO {
    private Long shopId;
    private String name;
    private String address;
    private String imageUrl;
    private String tele_number;
    private String email;
    private String businessName;
    private String businessDescription;


    public FoodShopDTO(Long shopId, String name, String imageUrl) {
        this.shopId = shopId;
        this.name = name;
        this.imageUrl = imageUrl;
    }

}