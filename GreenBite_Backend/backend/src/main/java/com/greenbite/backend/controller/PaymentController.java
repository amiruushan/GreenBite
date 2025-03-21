package com.greenbite.backend.controller;

import com.greenbite.backend.service.PaymentService;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @PostMapping("/create")
    public ResponseEntity<Map<String, String>> createPayment(@RequestParam Long amount, @RequestParam String currency) {
        try {
            String clientSecret = paymentService.createPaymentIntent(amount, currency);

            // Wrap response in a JSON object
            Map<String, String> response = new HashMap<>();
            response.put("clientSecret", clientSecret);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            // Wrap error message in a JSON object
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", e.getMessage());

            return ResponseEntity.badRequest().body(errorResponse);
        }
    }
}


