package com.example.myonlinemart.dto;

import java.time.Instant;
import java.util.List;

public record ErrorResponse(
        String error,
        String message,
        List<String> details,
        Instant timestamp
) {
}
