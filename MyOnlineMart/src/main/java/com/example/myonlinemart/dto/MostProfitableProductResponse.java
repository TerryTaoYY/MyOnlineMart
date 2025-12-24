package com.example.myonlinemart.dto;

import java.math.BigDecimal;

public record MostProfitableProductResponse(
        Long productId,
        String description,
        BigDecimal totalProfit
) {
}
