package com.example.myonlinemart.controller;

import com.example.myonlinemart.dto.MostProfitableProductResponse;
import com.example.myonlinemart.dto.PopularProductResponse;
import com.example.myonlinemart.dto.TotalItemsSoldResponse;
import com.example.myonlinemart.service.OrderService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/summary")
public class AdminSummaryController {

    private final OrderService orderService;

    public AdminSummaryController(OrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping("/profit")
    public ResponseEntity<MostProfitableProductResponse> mostProfitableProduct() {
        return ResponseEntity.ok(orderService.getMostProfitableProduct());
    }

    @GetMapping("/popular")
    public ResponseEntity<List<PopularProductResponse>> topPopularProducts() {
        return ResponseEntity.ok(orderService.getTopPopularProducts());
    }

    @GetMapping("/total-sold")
    public ResponseEntity<TotalItemsSoldResponse> totalItemsSold() {
        return ResponseEntity.ok(orderService.getTotalItemsSold());
    }
}
