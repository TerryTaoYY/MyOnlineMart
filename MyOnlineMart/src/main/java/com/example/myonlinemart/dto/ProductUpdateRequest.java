package com.example.myonlinemart.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public record ProductUpdateRequest(
        @Size(max = 2000) String description,
        @DecimalMin("0.00") BigDecimal wholesalePrice,
        @DecimalMin("0.00") BigDecimal retailPrice,
        @Min(0) Integer stockQuantity
) {
}
