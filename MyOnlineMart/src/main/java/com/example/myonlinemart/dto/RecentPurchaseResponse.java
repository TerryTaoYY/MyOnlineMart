package com.example.myonlinemart.dto;

import java.time.Instant;

public record RecentPurchaseResponse(
        Long productId,
        String description,
        Instant lastPurchasedAt
) {
}
