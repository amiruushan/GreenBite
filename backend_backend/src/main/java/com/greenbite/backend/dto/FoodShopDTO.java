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
}
