package com.example.myonlinemart.dto;

import com.example.myonlinemart.entity.OrderStatus;
import java.time.Instant;

public record BuyerOrderSummaryResponse(
        Long id,
        Instant placedAt,
        OrderStatus status
) {
}
