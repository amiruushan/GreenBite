package com.greenbite.backend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.greenbite.backend.dto.AddPointsDTO;
import com.greenbite.backend.dto.LocationUpdateDTO;
import com.greenbite.backend.dto.UserDTO;
import com.greenbite.backend.model.User;
import com.greenbite.backend.repository.UserRepository;
import com.greenbite.backend.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;
    private final UserRepository userRepository;

    public UserController(UserService userService, UserRepository userRepository) {
        this.userService = userService;
        this.userRepository = userRepository;
    }

    // Get user by ID
    @GetMapping("/{id}")
    public UserDTO getUserById(@PathVariable Long id) {
        return userService.getUserById(id);
    }

    // Update user details
    @PutMapping("/update")
    public ResponseEntity<UserDTO> updateUser(
            @RequestPart("user") String userJson,
            @RequestPart(value = "profilePicture", required = false) MultipartFile profilePicture) throws IOException {
        // Convert the JSON string to a UserDTO object
        ObjectMapper objectMapper = new ObjectMapper();
        UserDTO userDTO = objectMapper.readValue(userJson, UserDTO.class);

        // Update the user profile
        UserDTO updatedUser = userService.updateUser(userDTO, profilePicture);
        return ResponseEntity.ok(updatedUser);
    }
    @PostMapping("/add-points")
    public ResponseEntity<String> addPoints(@RequestBody AddPointsDTO addPointsDTO) {
        userService.addPoints(addPointsDTO.getUserId(), addPointsDTO.getNormalPoints());
        return ResponseEntity.ok("Points updated successfully");
    }

    @GetMapping("/points")
    public ResponseEntity<Map<String, Integer>> getPoints(@RequestParam Long userId) {

        int normalPoints = userService.getNormalPoints(userId);
        int greenBitePoints = userService.getGreenBitePoints(userId);

        Map<String, Integer> response = new HashMap<>();
        response.put("normalPoints", normalPoints);
        response.put("greenBitePoints", greenBitePoints);

        return ResponseEntity.ok(response);
    }
    @PutMapping("/updateLocation")
    public ResponseEntity<String> updateUserLocation(@RequestBody LocationUpdateDTO dto) {
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setLatitude(dto.getLatitude());
        user.setLongitude(dto.getLongitude());
        userRepository.save(user);

        return ResponseEntity.ok("User location updated successfully");
    }
    @GetMapping("/location/{userId}")
    public ResponseEntity<Map<String, Double>> getUserLocation(@PathVariable Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Map<String, Double> location = new HashMap<>();
        location.put("latitude", user.getLatitude());
        location.put("longitude", user.getLongitude());

        return ResponseEntity.ok(location);
    }

}

