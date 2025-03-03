package com.greenbite.backend.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RegisterUserDto {
    private String email;
    private String password;
    private String username;
    private String firstName; // ✅ New Field
    private String surname; // ✅ New Field
    private String district; // ✅ New Field
    private String address;
    private String role;
}
