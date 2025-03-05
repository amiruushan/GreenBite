package com.greenbite.backend.service;

import com.greenbite.backend.dto.UserDTO;
import com.greenbite.backend.model.Coupon;
import com.greenbite.backend.model.CouponManagement;
import com.greenbite.backend.model.User;
import com.greenbite.backend.repository.CouponRepository;
import com.greenbite.backend.repository.CouponManagementRepository;
import com.greenbite.backend.repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final CouponRepository couponRepository;
    private final CouponManagementRepository couponManagementRepository;

    public UserService(UserRepository userRepository, CouponRepository couponRepository, CouponManagementRepository couponManagementRepository) {
        this.userRepository = userRepository;
        this.couponRepository = couponRepository;
        this.couponManagementRepository = couponManagementRepository;
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

    public void purchaseCoupon(Long userId, Long couponId, String couponCode) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Coupon coupon = couponRepository.findById(couponId)
                .orElseThrow(() -> new RuntimeException("Coupon not found"));

        if (user.getGreenBitePoints() < coupon.getCost()) {
            throw new RuntimeException("Not enough Green Bite Points");
        }

        // Deduct GBP
        user.setGreenBitePoints(user.getGreenBitePoints() - coupon.getCost());
        userRepository.save(user);

        // Save to CouponManagement with discount
        CouponManagement couponManagement = new CouponManagement(user, coupon, couponCode, coupon.getDiscount());
        couponManagementRepository.save(couponManagement);
    }
}
