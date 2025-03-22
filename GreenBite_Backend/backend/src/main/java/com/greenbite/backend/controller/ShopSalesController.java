package com.greenbite.backend.controller;

import com.greenbite.backend.service.ShopSalesService;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;

@RestController
@RequestMapping("/api/sales")
public class ShopSalesController {

    private final ShopSalesService shopSalesService;

    public ShopSalesController(ShopSalesService shopSalesService) {
        this.shopSalesService = shopSalesService;
    }

    @GetMapping("/total")
    public float getTotalSales(@RequestBody Map<String, String> request) {
        System.out.println("total");
        Long shopId = Long.parseLong(request.get("shopId"));
        LocalDateTime startDate = LocalDateTime.parse(request.get("startDate"), DateTimeFormatter.ISO_DATE_TIME);
        LocalDateTime endDate = LocalDateTime.parse(request.get("endDate"), DateTimeFormatter.ISO_DATE_TIME);
        return shopSalesService.calculateTotalSales(shopId, startDate, endDate);
    }
}