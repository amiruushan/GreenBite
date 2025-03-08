package com.greenbite.backend.controller;

import com.greenbite.backend.dto.AddPointsDTO;
import com.greenbite.backend.dto.LocationUpdateDTO;
import com.greenbite.backend.dto.UserDTO;
import com.greenbite.backend.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    // Get user by ID
    @GetMapping("/{id}")
    public UserDTO getUserById(@PathVariable Long id) {
        System.out.println("Get working");
        return userService.getUserById(id);
    }

    // Update user details
    @PutMapping("/update")
    public UserDTO updateUser(@RequestBody UserDTO userDTO) {
        System.out.println("Update working");
        return userService.updateUser(userDTO);
    }
    @PostMapping("/add-points")
    public ResponseEntity<String> addPoints(@RequestBody AddPointsDTO addPointsDTO) {
        userService.addPoints(addPointsDTO.getUserId(), addPointsDTO.getNormalPoints());
        return ResponseEntity.ok("Points updated successfully");
    }

    @GetMapping("/points")
    public ResponseEntity<Map<String, Integer>> getPoints(@RequestParam Long userId) {
        System.out.println("Get Points");
        int normalPoints = userService.getNormalPoints(userId);
        int greenBitePoints = userService.getGreenBitePoints(userId);

        Map<String, Integer> response = new HashMap<>();
        response.put("normalPoints", normalPoints);
        response.put("greenBitePoints", greenBitePoints);

        return ResponseEntity.ok(response);
    }
    @PutMapping("/updateLocation")
    public ResponseEntity<UserDTO> updateUserLocation(@RequestBody LocationUpdateDTO locationUpdateDTO) {
        System.out.println("LOcatio000000ekirwrwhkledhk");
        UserDTO updatedUser = userService.updateUserLocation(locationUpdateDTO);
        return ResponseEntity.ok(updatedUser);
    }



}

