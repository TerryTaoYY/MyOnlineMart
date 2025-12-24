package com.example.myonlinemart.service;

import com.example.myonlinemart.dto.AdminOrderDetailResponse;
import com.example.myonlinemart.dto.AdminOrderItemResponse;
import com.example.myonlinemart.dto.AdminOrderSummaryResponse;
import com.example.myonlinemart.dto.BuyerOrderDetailResponse;
import com.example.myonlinemart.dto.BuyerOrderItemResponse;
import com.example.myonlinemart.dto.BuyerOrderSummaryResponse;
import com.example.myonlinemart.dto.CreateOrderRequest;
import com.example.myonlinemart.dto.MostProfitableProductResponse;
import com.example.myonlinemart.dto.OrderStatusResponse;
import com.example.myonlinemart.dto.PopularProductResponse;
import com.example.myonlinemart.dto.ProductFrequencyResponse;
import com.example.myonlinemart.dto.RecentPurchaseResponse;
import com.example.myonlinemart.dto.TotalItemsSoldResponse;
import com.example.myonlinemart.entity.Order;
import com.example.myonlinemart.entity.OrderItem;
import com.example.myonlinemart.entity.OrderStatus;
import com.example.myonlinemart.entity.Product;
import com.example.myonlinemart.entity.UserAccount;
import com.example.myonlinemart.exception.NotEnoughInventoryException;
import com.example.myonlinemart.exception.ResourceNotFoundException;
import com.example.myonlinemart.exception.UnauthorizedAccessException;
import com.example.myonlinemart.repository.OrderDao;
import com.example.myonlinemart.repository.ProductDao;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OrderService {

    private final OrderDao orderDao;
    private final ProductDao productDao;
    private final UserService userService;

    public OrderService(OrderDao orderDao, ProductDao productDao, UserService userService) {
        this.orderDao = orderDao;
        this.productDao = productDao;
        this.userService = userService;
    }

    @Transactional
    public BuyerOrderDetailResponse createOrder(Long buyerId, CreateOrderRequest request) {
        if (request.items() == null || request.items().isEmpty()) {
            throw new IllegalArgumentException("Order must contain at least one item.");
        }
        UserAccount buyer = userService.getById(buyerId);
        Map<Long, Integer> quantityByProduct = request.items().stream()
                .collect(Collectors.toMap(
                        item -> item.productId(),
                        item -> item.quantity(),
                        Integer::sum));

        List<Product> products = quantityByProduct.keySet().stream()
                .map(productId -> productDao.findById(productId)
                        .orElseThrow(() -> new ResourceNotFoundException("Product not found.")))
                .collect(Collectors.toList());

        for (Product product : products) {
            int requested = quantityByProduct.get(product.getId());
            if (product.getStockQuantity() < requested) {
                throw new NotEnoughInventoryException("Not enough inventory for product " + product.getId());
            }
        }

        Instant now = Instant.now();
        Order order = Order.builder()
                .buyer(buyer)
                .status(OrderStatus.PROCESSING)
                .placedAt(now)
                .updatedAt(now)
                .items(new ArrayList<>())
                .build();

        for (Product product : products) {
            int quantity = quantityByProduct.get(product.getId());
            product.setStockQuantity(product.getStockQuantity() - quantity);
            product.setUpdatedAt(now);
            OrderItem orderItem = OrderItem.builder()
                    .order(order)
                    .product(product)
                    .quantity(quantity)
                    .unitWholesalePrice(product.getWholesalePrice())
                    .unitRetailPrice(product.getRetailPrice())
                    .build();
            order.getItems().add(orderItem);
        }

        orderDao.save(order);
        return mapBuyerOrderDetail(order);
    }

    @Transactional(readOnly = true)
    public List<BuyerOrderSummaryResponse> listBuyerOrders(Long buyerId) {
        return orderDao.findByBuyerId(buyerId).stream()
                .map(order -> new BuyerOrderSummaryResponse(
                        order.getId(),
                        order.getPlacedAt(),
                        order.getStatus()))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public BuyerOrderDetailResponse getBuyerOrder(Long buyerId, Long orderId) {
        Order order = orderDao.findWithItems(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found."));
        if (!order.getBuyer().getId().equals(buyerId)) {
            throw new UnauthorizedAccessException("Cannot access another user's order.");
        }
        return mapBuyerOrderDetail(order);
    }

    @Transactional
    public OrderStatusResponse cancelBuyerOrder(Long buyerId, Long orderId) {
        Order order = orderDao.findWithItems(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found."));
        if (!order.getBuyer().getId().equals(buyerId)) {
            throw new UnauthorizedAccessException("Cannot cancel another user's order.");
        }
        return cancelOrderInternal(order);
    }

    @Transactional(readOnly = true)
    public List<AdminOrderSummaryResponse> listAdminOrders(int page, int pageSize) {
        int offset = page * pageSize;
        return orderDao.findAllPaged(offset, pageSize).stream()
                .map(order -> new AdminOrderSummaryResponse(
                        order.getId(),
                        order.getPlacedAt(),
                        order.getStatus(),
                        order.getBuyer().getUsername()))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public AdminOrderDetailResponse getAdminOrder(Long orderId) {
        Order order = orderDao.findWithItems(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found."));
        return mapAdminOrderDetail(order);
    }

    @Transactional
    public OrderStatusResponse completeOrder(Long orderId) {
        Order order = orderDao.findWithItems(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found."));
        if (order.getStatus() == OrderStatus.CANCELED) {
            throw new IllegalStateException("Canceled order cannot be completed.");
        }
        if (order.getStatus() == OrderStatus.COMPLETED) {
            throw new IllegalStateException("Order is already completed.");
        }
        order.setStatus(OrderStatus.COMPLETED);
        order.setUpdatedAt(Instant.now());
        return new OrderStatusResponse(order.getId(), order.getStatus());
    }

    @Transactional
    public OrderStatusResponse cancelOrderAsAdmin(Long orderId) {
        Order order = orderDao.findWithItems(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found."));
        return cancelOrderInternal(order);
    }

    @Transactional(readOnly = true)
    public List<ProductFrequencyResponse> getTopPurchasedItems(Long buyerId) {
        return orderDao.findTopPurchasedItems(buyerId, 3).stream()
                .map(result -> new ProductFrequencyResponse(
                        (Long) result[0],
                        (String) result[1],
                        (Long) result[2]))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<RecentPurchaseResponse> getRecentPurchasedItems(Long buyerId) {
        return orderDao.findRecentPurchasedItems(buyerId, 3).stream()
                .map(result -> new RecentPurchaseResponse(
                        (Long) result[0],
                        (String) result[1],
                        (Instant) result[2]))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public MostProfitableProductResponse getMostProfitableProduct() {
        return orderDao.findMostProfitableProduct()
                .map(result -> new MostProfitableProductResponse(
                        (Long) result[0],
                        (String) result[1],
                        (java.math.BigDecimal) result[2]))
                .orElseThrow(() -> new ResourceNotFoundException("No completed orders yet."));
    }

    @Transactional(readOnly = true)
    public List<PopularProductResponse> getTopPopularProducts() {
        return orderDao.findTopPopularProducts(3).stream()
                .map(result -> new PopularProductResponse(
                        (Long) result[0],
                        (String) result[1],
                        (Long) result[2]))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public TotalItemsSoldResponse getTotalItemsSold() {
        return new TotalItemsSoldResponse(orderDao.findTotalItemsSold());
    }

    private OrderStatusResponse cancelOrderInternal(Order order) {
        if (order.getStatus() == OrderStatus.COMPLETED) {
            throw new IllegalStateException("Completed order cannot be canceled.");
        }
        if (order.getStatus() == OrderStatus.CANCELED) {
            throw new IllegalStateException("Order is already canceled.");
        }
        Instant now = Instant.now();
        order.setStatus(OrderStatus.CANCELED);
        order.setUpdatedAt(now);
        for (OrderItem item : order.getItems()) {
            Product product = item.getProduct();
            product.setStockQuantity(product.getStockQuantity() + item.getQuantity());
            product.setUpdatedAt(now);
        }
        return new OrderStatusResponse(order.getId(), order.getStatus());
    }

    private BuyerOrderDetailResponse mapBuyerOrderDetail(Order order) {
        List<BuyerOrderItemResponse> items = order.getItems().stream()
                .map(item -> new BuyerOrderItemResponse(
                        item.getProduct().getId(),
                        item.getProduct().getDescription(),
                        item.getQuantity(),
                        item.getUnitRetailPrice()))
                .collect(Collectors.toList());
        return new BuyerOrderDetailResponse(order.getId(), order.getPlacedAt(), order.getStatus(), items);
    }

    private AdminOrderDetailResponse mapAdminOrderDetail(Order order) {
        List<AdminOrderItemResponse> items = order.getItems().stream()
                .map(item -> new AdminOrderItemResponse(
                        item.getProduct().getId(),
                        item.getProduct().getDescription(),
                        item.getQuantity(),
                        item.getUnitWholesalePrice(),
                        item.getUnitRetailPrice()))
                .collect(Collectors.toList());
        return new AdminOrderDetailResponse(
                order.getId(),
                order.getPlacedAt(),
                order.getStatus(),
                order.getBuyer().getUsername(),
                items);
    }
}
