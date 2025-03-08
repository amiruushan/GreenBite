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
    private String imageUrl;
    //    private String description;
    private String tele_number;

    public FoodShopDTO(Long shopId, String name, String imageUrl) {
        this.shopId = shopId;
        this.name = name;
        this.imageUrl = imageUrl;
    }

}