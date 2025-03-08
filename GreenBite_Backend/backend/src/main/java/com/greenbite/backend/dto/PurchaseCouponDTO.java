package com.greenbite.backend.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PurchaseCouponDTO {
    private Long userId;
    private Long couponId;
    private String couponCode;
}
