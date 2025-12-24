package com.example.myonlinemart.dto;

public record PopularProductResponse(
        Long productId,
        String description,
        Long totalQuantity
) {
}
