package com.greenbite.backend.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LocationUpdateDTO {
    private Long userId;
    private Double latitude;
    private Double longitude;
}
