package com.greenbite.backend.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PurchaseDealDTO {
    private Long userId;
    private Long dealId;
    private String couponCode;
}