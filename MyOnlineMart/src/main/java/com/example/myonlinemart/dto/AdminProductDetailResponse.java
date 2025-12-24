package com.example.myonlinemart.dto;

import java.math.BigDecimal;

public record AdminProductDetailResponse(
        Long id,
        String description,
        BigDecimal wholesalePrice,
        BigDecimal retailPrice,
        Integer stockQuantity
) {
}
