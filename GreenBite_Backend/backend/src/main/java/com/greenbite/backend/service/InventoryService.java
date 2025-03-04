package com.greenbite.backend.service;

import com.greenbite.backend.model.Deal;
import com.greenbite.backend.model.Inventory;
import com.greenbite.backend.model.User;
import com.greenbite.backend.repository.DealRepository;
import com.greenbite.backend.repository.InventoryRepository;
import com.greenbite.backend.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class InventoryService {
    private final InventoryRepository inventoryRepository;
    private final UserRepository userRepository;
    private final DealRepository dealRepository;

    public InventoryService(InventoryRepository inventoryRepository, UserRepository userRepository, DealRepository dealRepository) {
        this.inventoryRepository = inventoryRepository;
        this.userRepository = userRepository;
        this.dealRepository = dealRepository;
    }

    public List<Map<String, Object>> getUserInventory(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<Inventory> inventoryItems = inventoryRepository.findByUser(user);
        List<Map<String, Object>> inventoryData = new ArrayList<>();

        for (Inventory item : inventoryItems) {
            Map<String, Object> map = new HashMap<>();
            map.put("deal_name", item.getDeal().getTitle());
            map.put("coupon_code", item.getCouponCode());
            map.put("discount", item.getDiscount()); // ✅ Include discount
            map.put("redeemed", !item.isActive()); // ✅ Fix redeemed status
            inventoryData.add(map);
        }

        return inventoryData;
    }



    public void purchaseDeal(Long userId, Long dealId, String couponCode) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Deal deal = dealRepository.findById(dealId)
                .orElseThrow(() -> new RuntimeException("Deal not found"));

        if (user.getGreenBitePoints() < deal.getCost()) {
            throw new RuntimeException("Not enough Green Bite Points");
        }

        // Deduct GBP
        user.setGreenBitePoints(user.getGreenBitePoints() - deal.getCost());
        userRepository.save(user);

        // Save to inventory with discount
        Inventory inventory = new Inventory(user, deal, couponCode, deal.getDiscount());
        inventoryRepository.save(inventory);
    }



    public void redeemCoupon(String couponCode) {
        Optional<Inventory> inventoryOptional = inventoryRepository.findByCouponCode(couponCode);

        if (inventoryOptional.isPresent()) {
            Inventory inventory = inventoryOptional.get();

            if (inventory.isActive()) { // ✅ Check if it's already redeemed
                inventory.setActive(false); // ✅ Mark as redeemed
                inventoryRepository.save(inventory); // ✅ Save changes
                System.out.println("Coupon " + couponCode + " redeemed successfully.");
            } else {
                throw new RuntimeException("Coupon already redeemed!");
            }
        } else {
            throw new RuntimeException("Coupon not found!");
        }
    }



}