package com.example.myonlinemart.controller;

import com.example.myonlinemart.dto.ProductSummaryResponse;
import com.example.myonlinemart.service.CurrentUserService;
import com.example.myonlinemart.service.WatchlistService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/buyer/watchlist")
public class BuyerWatchlistController {

    private final WatchlistService watchlistService;
    private final CurrentUserService currentUserService;

    public BuyerWatchlistController(WatchlistService watchlistService, CurrentUserService currentUserService) {
        this.watchlistService = watchlistService;
        this.currentUserService = currentUserService;
    }

    @GetMapping
    public ResponseEntity<List<ProductSummaryResponse>> listWatchlist() {
        Long userId = currentUserService.getCurrentUser().getId();
        return ResponseEntity.ok(watchlistService.listWatchlist(userId));
    }

    @PostMapping("/{productId}")
    public ResponseEntity<Void> addProduct(@PathVariable Long productId) {
        Long userId = currentUserService.getCurrentUser().getId();
        watchlistService.addToWatchlist(userId, productId);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @DeleteMapping("/{productId}")
    public ResponseEntity<Void> removeProduct(@PathVariable Long productId) {
        Long userId = currentUserService.getCurrentUser().getId();
        watchlistService.removeFromWatchlist(userId, productId);
        return ResponseEntity.noContent().build();
    }
}
