package com.greenbite.backend.controller;

import com.greenbite.backend.dto.UserDTO;
import com.greenbite.backend.service.UserService;
import org.springframework.web.bind.annotation.*;

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
}

