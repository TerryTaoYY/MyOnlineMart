package com.example.myonlinemart.dto;

public record AuthResponse(
        String token,
        String role,
        String username,
        Long userId
) {
}
