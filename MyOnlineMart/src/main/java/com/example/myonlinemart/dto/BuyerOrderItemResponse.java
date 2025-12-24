package com.example.myonlinemart.dto;

import java.math.BigDecimal;

public record BuyerOrderItemResponse(
        Long productId,
        String description,
        Integer quantity,
        BigDecimal unitRetailPrice
) {
}
