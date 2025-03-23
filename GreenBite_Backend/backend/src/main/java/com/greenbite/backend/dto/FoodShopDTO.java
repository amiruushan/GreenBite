package com.greenbite.backend.dto;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Data
@Getter
@Setter

public class FoodShopDTO {
    private Long shopId;
    private String name;
    private String photo;
    private String address;      // Add address
    private String phoneNumber;  // Rename tele_number to phoneNumber
    private String email;
    private String businessDescription;
    private double latitude;
    private double longitude;
    private LocalDate licenseExpirationDate;

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

    public FoodShopDTO(Long shopId, String name, String photo, String address, String phoneNumber, double latitude, double longitude, LocalDate licenseExpirationDate) {
        this.shopId = shopId;
        this.name = name;
        this.photo = photo;
        this.address = address;
        this.phoneNumber = phoneNumber;
        this.latitude = latitude;
        this.longitude = longitude;
        this.licenseExpirationDate=licenseExpirationDate;
    }
    public FoodShopDTO(Long shopId, String name, String photo, String address, String phoneNumber, double latitude, double longitude, LocalDate licenseExpirationDate,String businessDescription) {
        this.shopId = shopId;
        this.name = name;
        this.photo = photo;
        this.address = address;
        this.phoneNumber = phoneNumber;
        this.latitude = latitude;
        this.longitude = longitude;
        this.licenseExpirationDate=licenseExpirationDate;
        this.businessDescription=businessDescription;
    }
}

