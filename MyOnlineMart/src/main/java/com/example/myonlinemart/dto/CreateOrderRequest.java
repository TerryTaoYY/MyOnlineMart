package com.example.myonlinemart.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public record CreateOrderRequest(
        @NotNull @NotEmpty List<@Valid OrderItemRequest> items
) {
}
