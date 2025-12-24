package com.example.myonlinemart.dto;

import java.math.BigDecimal;

public record ProductDetailResponse(
        Long id,
        String description,
        BigDecimal retailPrice
) {
}
