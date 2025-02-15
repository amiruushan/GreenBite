package com.greenbite.backend.controller;


import com.greenbite.backend.service.PaymentService;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @PostMapping("/create")
    public ResponseEntity<String> createPayment(@RequestParam Long amount, @RequestParam String currency) {
        System.out.println("Payment api");
        try {
            String clientSecret = paymentService.createPaymentIntent(amount, currency);
            return ResponseEntity.ok(clientSecret);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }
}

