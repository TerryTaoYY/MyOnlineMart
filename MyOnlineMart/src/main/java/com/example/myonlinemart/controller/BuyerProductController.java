package com.example.myonlinemart.controller;

import com.example.myonlinemart.dto.ProductDetailResponse;
import com.example.myonlinemart.dto.ProductSummaryResponse;
import com.example.myonlinemart.service.ProductService;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/buyer/products")
public class BuyerProductController {

    private final ProductService productService;

    public BuyerProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public ResponseEntity<List<ProductSummaryResponse>> listAvailableProducts() {
        return ResponseEntity.ok(productService.listAvailableProducts());
    }

    @GetMapping("/{productId}")
    public ResponseEntity<ProductDetailResponse> getProduct(@PathVariable Long productId) {
        return ResponseEntity.ok(productService.getProductForBuyer(productId));
    }
}
