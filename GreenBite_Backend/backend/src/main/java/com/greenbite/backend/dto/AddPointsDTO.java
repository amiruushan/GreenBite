package com.greenbite.backend.dto;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AddPointsDTO {
    private Long userId;
    private int normalPoints;
}
