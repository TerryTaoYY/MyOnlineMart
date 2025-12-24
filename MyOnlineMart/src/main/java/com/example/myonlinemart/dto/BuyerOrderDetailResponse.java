package com.example.myonlinemart.dto;

import com.example.myonlinemart.entity.OrderStatus;
import java.time.Instant;
import java.util.List;

public record BuyerOrderDetailResponse(
        Long id,
        Instant placedAt,
        OrderStatus status,
        List<BuyerOrderItemResponse> items
) {
}
