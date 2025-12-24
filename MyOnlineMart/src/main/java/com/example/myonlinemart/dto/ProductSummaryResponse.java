package com.example.myonlinemart.dto;

import java.math.BigDecimal;

public record ProductSummaryResponse(
        Long id,
        String description,
        BigDecimal retailPrice
) {
}
