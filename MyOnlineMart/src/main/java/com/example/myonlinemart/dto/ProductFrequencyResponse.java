package com.example.myonlinemart.dto;

public record ProductFrequencyResponse(
        Long productId,
        String description,
        Long totalQuantity
) {
}
