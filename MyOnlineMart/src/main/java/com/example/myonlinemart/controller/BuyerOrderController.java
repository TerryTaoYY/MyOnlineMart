package com.example.myonlinemart.controller;

import com.example.myonlinemart.dto.BuyerOrderDetailResponse;
import com.example.myonlinemart.dto.BuyerOrderSummaryResponse;
import com.example.myonlinemart.dto.CreateOrderRequest;
import com.example.myonlinemart.dto.OrderStatusResponse;
import com.example.myonlinemart.dto.ProductFrequencyResponse;
import com.example.myonlinemart.dto.RecentPurchaseResponse;
import com.example.myonlinemart.exception.RequestValidationException;
import com.example.myonlinemart.service.CurrentUserService;
import com.example.myonlinemart.service.OrderService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/buyer/orders")
public class BuyerOrderController {

    private final OrderService orderService;
    private final CurrentUserService currentUserService;

    public BuyerOrderController(OrderService orderService, CurrentUserService currentUserService) {
        this.orderService = orderService;
        this.currentUserService = currentUserService;
    }

    @GetMapping
    public ResponseEntity<List<BuyerOrderSummaryResponse>> listOrders() {
        Long buyerId = currentUserService.getCurrentUser().getId();
        return ResponseEntity.ok(orderService.listBuyerOrders(buyerId));
    }

    @GetMapping("/{orderId}")
    public ResponseEntity<BuyerOrderDetailResponse> getOrder(@PathVariable Long orderId) {
        Long buyerId = currentUserService.getCurrentUser().getId();
        return ResponseEntity.ok(orderService.getBuyerOrder(buyerId, orderId));
    }

    @PostMapping
    public ResponseEntity<BuyerOrderDetailResponse> createOrder(@Valid @RequestBody CreateOrderRequest request,
                                                                BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            throw new RequestValidationException("Validation failed", collectErrors(bindingResult));
        }
        Long buyerId = currentUserService.getCurrentUser().getId();
        BuyerOrderDetailResponse response = orderService.createOrder(buyerId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PatchMapping("/{orderId}/cancel")
    public ResponseEntity<OrderStatusResponse> cancelOrder(@PathVariable Long orderId) {
        Long buyerId = currentUserService.getCurrentUser().getId();
        return ResponseEntity.ok(orderService.cancelBuyerOrder(buyerId, orderId));
    }

    @GetMapping("/top/frequent")
    public ResponseEntity<List<ProductFrequencyResponse>> topFrequentItems() {
        Long buyerId = currentUserService.getCurrentUser().getId();
        return ResponseEntity.ok(orderService.getTopPurchasedItems(buyerId));
    }

    @GetMapping("/top/recent")
    public ResponseEntity<List<RecentPurchaseResponse>> topRecentItems() {
        Long buyerId = currentUserService.getCurrentUser().getId();
        return ResponseEntity.ok(orderService.getRecentPurchasedItems(buyerId));
    }

    private List<String> collectErrors(BindingResult bindingResult) {
        return bindingResult.getFieldErrors().stream()
                .map(this::formatFieldError)
                .collect(Collectors.toList());
    }

    private String formatFieldError(FieldError error) {
        return error.getField() + ": " + error.getDefaultMessage();
    }
}
