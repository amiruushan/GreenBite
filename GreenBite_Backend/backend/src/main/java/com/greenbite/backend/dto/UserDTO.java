package com.greenbite.backend.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserDTO {
    private Long id;
    private String username;
    private String email;
    private String profilePictureUrl;
    private String phoneNumber;
    private String address;
    private int shopId;
}

