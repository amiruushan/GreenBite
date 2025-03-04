package com.greenbite.backend.service;

import com.greenbite.backend.dto.UserDTO;
import com.greenbite.backend.model.Deal;
import com.greenbite.backend.model.Inventory;
import com.greenbite.backend.model.User;
import com.greenbite.backend.repository.DealRepository;
import com.greenbite.backend.repository.InventoryRepository;
import com.greenbite.backend.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final DealRepository dealRepository;
    private final InventoryRepository inventoryRepository;

    public UserService(UserRepository userRepository, DealRepository dealRepository, InventoryRepository inventoryRepository) {
        this.userRepository = userRepository;
        this.dealRepository = dealRepository;
        this.inventoryRepository = inventoryRepository;
    }

    public UserDTO getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return convertToDTO(user);
    }

    public UserDTO updateUser(UserDTO userDTO) {
        User user = userRepository.findById(userDTO.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setUsername(userDTO.getUsername());
        user.setEmail(userDTO.getEmail());
        user.setProfilePictureUrl(userDTO.getProfilePictureUrl());
        user.setPhoneNumber(userDTO.getPhoneNumber());
        user.setAddress(userDTO.getAddress());

        user = userRepository.save(user);
        return convertToDTO(user);
    }

    private UserDTO convertToDTO(User user) {
        return new UserDTO(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getProfilePictureUrl(),
                user.getPhoneNumber(),
                user.getAddress()
        );
    }
    public void addPoints(Long userId, int earnedPoints) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Add normal points
        user.setNormalPoints(user.getNormalPoints() + earnedPoints);

        // Convert to Green Bite points if threshold is reached (100 normal points = 1 Green Bite point)
        if (user.getNormalPoints() >= 100) {
            int convertedPoints = user.getNormalPoints() / 100;  // Number of Green Bite points to add
            user.setGreenBitePoints(user.getGreenBitePoints() + convertedPoints);
            user.setNormalPoints(user.getNormalPoints() % 100); // Remaining normal points after conversion
        }

        userRepository.save(user);
    }

    public int getNormalPoints(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return user.getNormalPoints();
    }

    public int getGreenBitePoints(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return user.getGreenBitePoints();
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

        // Save to inventory
        Inventory inventory = new Inventory(user, deal, couponCode);
        inventoryRepository.save(inventory);
    }
}
