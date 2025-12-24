package com.example.myonlinemart.service;

import com.example.myonlinemart.dto.AdminProductDetailResponse;
import com.example.myonlinemart.dto.ProductCreateRequest;
import com.example.myonlinemart.dto.ProductDetailResponse;
import com.example.myonlinemart.dto.ProductSummaryResponse;
import com.example.myonlinemart.dto.ProductUpdateRequest;
import com.example.myonlinemart.entity.Product;
import com.example.myonlinemart.exception.ResourceNotFoundException;
import com.example.myonlinemart.repository.ProductDao;
import java.time.Instant;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ProductService {

    private final ProductDao productDao;

    public ProductService(ProductDao productDao) {
        this.productDao = productDao;
    }

    @Transactional(readOnly = true)
    public List<ProductSummaryResponse> listAvailableProducts() {
        return productDao.findInStock().stream()
                .map(product -> new ProductSummaryResponse(
                        product.getId(),
                        product.getDescription(),
                        product.getRetailPrice()))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ProductDetailResponse getProductForBuyer(Long productId) {
        Product product = productDao.findById(productId)
                .filter(found -> found.getStockQuantity() > 0)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found."));
        return new ProductDetailResponse(product.getId(), product.getDescription(), product.getRetailPrice());
    }

    @Transactional(readOnly = true)
    public List<AdminProductDetailResponse> listAllProducts() {
        return productDao.findAll().stream()
                .map(this::mapAdminProduct)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public AdminProductDetailResponse getProductForAdmin(Long productId) {
        Product product = productDao.findById(productId)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found."));
        return mapAdminProduct(product);
    }

    @Transactional
    public AdminProductDetailResponse createProduct(ProductCreateRequest request) {
        Instant now = Instant.now();
        Product product = Product.builder()
                .description(request.description())
                .wholesalePrice(request.wholesalePrice())
                .retailPrice(request.retailPrice())
                .stockQuantity(request.stockQuantity())
                .createdAt(now)
                .updatedAt(now)
                .build();
        productDao.save(product);
        return mapAdminProduct(product);
    }

    @Transactional
    public AdminProductDetailResponse updateProduct(Long productId, ProductUpdateRequest request) {
        Product product = productDao.findById(productId)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found."));
        if (request.description() != null) {
            product.setDescription(request.description());
        }
        if (request.wholesalePrice() != null) {
            product.setWholesalePrice(request.wholesalePrice());
        }
        if (request.retailPrice() != null) {
            product.setRetailPrice(request.retailPrice());
        }
        if (request.stockQuantity() != null) {
            product.setStockQuantity(request.stockQuantity());
        }
        product.setUpdatedAt(Instant.now());
        productDao.merge(product);
        return mapAdminProduct(product);
    }

    @Transactional(readOnly = true)
    public Product getEntity(Long productId) {
        return productDao.findById(productId)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found."));
    }

    private AdminProductDetailResponse mapAdminProduct(Product product) {
        return new AdminProductDetailResponse(
                product.getId(),
                product.getDescription(),
                product.getWholesalePrice(),
                product.getRetailPrice(),
                product.getStockQuantity());
    }
}
