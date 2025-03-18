package com.greenbite.backend.dto;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Getter
@Setter
public class FoodShopDTO {
    private Long shopId;
    private String name;
    private String photo;
    private String address;      // Add address
    private String phoneNumber;  // Rename tele_number to phoneNumber
    private double latitude;
    private double longitude;

    public FoodShopDTO(Long shopId, String name, String photo) {
        this.shopId = shopId;
        this.name = name;
        this.photo = photo;
    }

    public FoodShopDTO(Long shopId, String name, String photo, String address, String phoneNumber, double latitude, double longitude) {
        this.shopId = shopId;
        this.name = name;
        this.photo = photo;
        this.address = address;
        this.phoneNumber = phoneNumber;
        this.latitude = latitude;
        this.longitude = longitude;
    }
}

