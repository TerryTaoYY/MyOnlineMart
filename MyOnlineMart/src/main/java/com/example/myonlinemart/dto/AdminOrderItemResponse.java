package com.example.myonlinemart.dto;

import java.math.BigDecimal;

public record AdminOrderItemResponse(
        Long productId,
        String description,
        Integer quantity,
        BigDecimal unitWholesalePrice,
        BigDecimal unitRetailPrice
) {
}
