package com.greenbite.backend.controller;

import com.greenbite.backend.dto.UserDTO;
import com.greenbite.backend.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
@RestController
@RequestMapping("/api/admin")

public class AdminPanelController {

    private final UserService userService;
    public AdminPanelController(UserService userService){
        this.userService=userService;
    }

    @GetMapping("/listUsers")
    public ResponseEntity<List<UserDTO>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @DeleteMapping("/deleteUser/{userId}")
    public ResponseEntity<String> deleteUser(@PathVariable Long userId) {
        userService.deleteUserById(userId);
        return ResponseEntity.ok("User deleted successfully");
    }
}