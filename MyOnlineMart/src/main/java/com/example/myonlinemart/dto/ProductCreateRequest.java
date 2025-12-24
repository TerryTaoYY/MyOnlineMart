package com.example.myonlinemart.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public record ProductCreateRequest(
        @NotBlank @Size(max = 2000) String description,
        @NotNull @DecimalMin("0.00") BigDecimal wholesalePrice,
        @NotNull @DecimalMin("0.00") BigDecimal retailPrice,
        @NotNull @Min(0) Integer stockQuantity
) {
}
