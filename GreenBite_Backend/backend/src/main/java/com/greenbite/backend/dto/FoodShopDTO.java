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
    private Long id;
    private String name;
    private String address;
    private String tele_number;
    private String photo;
    private String email;
    private String businessName;
    private String businessDescription;
}
