package com.example.myonlinemart.dto;

import com.example.myonlinemart.entity.OrderStatus;

public record OrderStatusResponse(
        Long orderId,
        OrderStatus status
) {
}
