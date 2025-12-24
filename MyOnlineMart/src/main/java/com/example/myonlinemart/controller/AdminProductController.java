package com.example.myonlinemart.controller;

import com.example.myonlinemart.dto.AdminProductDetailResponse;
import com.example.myonlinemart.dto.ProductCreateRequest;
import com.example.myonlinemart.dto.ProductUpdateRequest;
import com.example.myonlinemart.exception.RequestValidationException;
import com.example.myonlinemart.service.ProductService;
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
@RequestMapping("/api/admin/products")
public class AdminProductController {

    private final ProductService productService;

    public AdminProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public ResponseEntity<List<AdminProductDetailResponse>> listProducts() {
        return ResponseEntity.ok(productService.listAllProducts());
    }

    @GetMapping("/{productId}")
    public ResponseEntity<AdminProductDetailResponse> getProduct(@PathVariable Long productId) {
        return ResponseEntity.ok(productService.getProductForAdmin(productId));
    }

    @PostMapping
    public ResponseEntity<AdminProductDetailResponse> createProduct(@Valid @RequestBody ProductCreateRequest request,
                                                                    BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            throw new RequestValidationException("Validation failed", collectErrors(bindingResult));
        }
        AdminProductDetailResponse response = productService.createProduct(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PatchMapping("/{productId}")
    public ResponseEntity<AdminProductDetailResponse> updateProduct(@PathVariable Long productId,
                                                                    @Valid @RequestBody ProductUpdateRequest request,
                                                                    BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            throw new RequestValidationException("Validation failed", collectErrors(bindingResult));
        }
        return ResponseEntity.ok(productService.updateProduct(productId, request));
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
