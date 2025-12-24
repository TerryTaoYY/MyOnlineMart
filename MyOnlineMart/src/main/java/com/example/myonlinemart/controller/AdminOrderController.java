package com.example.myonlinemart.controller;

import com.example.myonlinemart.dto.AdminOrderDetailResponse;
import com.example.myonlinemart.dto.AdminOrderSummaryResponse;
import com.example.myonlinemart.dto.OrderStatusResponse;
import com.example.myonlinemart.service.OrderService;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/orders")
public class AdminOrderController {

    private static final int PAGE_SIZE = 5;

    private final OrderService orderService;

    public AdminOrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping
    public ResponseEntity<List<AdminOrderSummaryResponse>> listOrders(
            @RequestParam(defaultValue = "0") int page) {
        return ResponseEntity.ok(orderService.listAdminOrders(page, PAGE_SIZE));
    }

    @GetMapping("/{orderId}")
    public ResponseEntity<AdminOrderDetailResponse> getOrder(@PathVariable Long orderId) {
        return ResponseEntity.ok(orderService.getAdminOrder(orderId));
    }

    @PatchMapping("/{orderId}/complete")
    public ResponseEntity<OrderStatusResponse> completeOrder(@PathVariable Long orderId) {
        return ResponseEntity.ok(orderService.completeOrder(orderId));
    }

    @PatchMapping("/{orderId}/cancel")
    public ResponseEntity<OrderStatusResponse> cancelOrder(@PathVariable Long orderId) {
        return ResponseEntity.ok(orderService.cancelOrderAsAdmin(orderId));
    }
}
