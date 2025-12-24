package com.example.myonlinemart.service;

import com.example.myonlinemart.dto.ProductSummaryResponse;
import com.example.myonlinemart.entity.Product;
import com.example.myonlinemart.entity.UserAccount;
import com.example.myonlinemart.entity.WatchlistEntry;
import com.example.myonlinemart.exception.ResourceConflictException;
import com.example.myonlinemart.exception.ResourceNotFoundException;
import com.example.myonlinemart.repository.WatchlistDao;
import java.time.Instant;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class WatchlistService {

    private final WatchlistDao watchlistDao;
    private final ProductService productService;
    private final UserService userService;

    public WatchlistService(WatchlistDao watchlistDao, ProductService productService, UserService userService) {
        this.watchlistDao = watchlistDao;
        this.productService = productService;
        this.userService = userService;
    }

    @Transactional
    public void addToWatchlist(Long userId, Long productId) {
        if (watchlistDao.findByUserAndProduct(userId, productId).isPresent()) {
            throw new ResourceConflictException("Product already in watchlist.");
        }
        UserAccount user = userService.getById(userId);
        Product product = productService.getEntity(productId);
        WatchlistEntry entry = WatchlistEntry.builder()
                .user(user)
                .product(product)
                .createdAt(Instant.now())
                .build();
        watchlistDao.save(entry);
    }

    @Transactional
    public void removeFromWatchlist(Long userId, Long productId) {
        WatchlistEntry entry = watchlistDao.findByUserAndProduct(userId, productId)
                .orElseThrow(() -> new ResourceNotFoundException("Product is not in watchlist."));
        watchlistDao.delete(entry);
    }

    @Transactional(readOnly = true)
    public List<ProductSummaryResponse> listWatchlist(Long userId) {
        return watchlistDao.findInStockByUser(userId).stream()
                .map(entry -> {
                    Product product = entry.getProduct();
                    return new ProductSummaryResponse(product.getId(), product.getDescription(), product.getRetailPrice());
                })
                .collect(Collectors.toList());
    }
}
