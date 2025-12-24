# MyOnlineMart API Documentation

Base URL: http://localhost:8080

All endpoints return JSON and use JWT authentication unless noted. Supply:

```
Authorization: Bearer <token>
```

## Authentication

### POST /api/auth/register
Registers a buyer account and returns a JWT.

Request body:
```
{
  "username": "buyer1",
  "email": "buyer1@example.com",
  "password": "Password123!"
}
```

Response (201):
```
{
  "token": "...",
  "role": "BUYER",
  "username": "buyer1",
  "userId": 3
}
```

### POST /api/auth/login
Logs in by username or email.

Request body:
```
{
  "usernameOrEmail": "buyer1",
  "password": "Password123!"
}
```

Response (200): same shape as register.

Errors:
- 401 InvalidCredentials: Incorrect credentials, please try again.

## Buyer APIs (role: BUYER)

### GET /api/buyer/products
Returns in-stock products only (no stock quantity shown).

Response (200):
```
[
  {"id": 1, "description": "Organic Apples", "retailPrice": 2.75}
]
```

### GET /api/buyer/products/{productId}
Returns product detail (no stock quantity shown).

### POST /api/buyer/orders
Creates an order in PROCESSING status. Deducts stock.

Request body:
```
{
  "items": [
    {"productId": 1, "quantity": 2},
    {"productId": 2, "quantity": 1}
  ]
}
```

Response (201):
```
{
  "id": 10,
  "placedAt": "2025-01-01T10:00:00Z",
  "status": "PROCESSING",
  "items": [
    {"productId": 1, "description": "Organic Apples", "quantity": 2, "unitRetailPrice": 2.75}
  ]
}
```

Errors:
- 409 NotEnoughInventory when requested quantity exceeds stock.

### GET /api/buyer/orders
Lists orders for the current buyer.

### GET /api/buyer/orders/{orderId}
Returns order details for current buyer only.

### PATCH /api/buyer/orders/{orderId}/cancel
Cancels a PROCESSING order and restores stock.

### GET /api/buyer/orders/top/frequent
Top 3 most frequently purchased items (excludes canceled orders).

### GET /api/buyer/orders/top/recent
Top 3 most recently purchased items (excludes canceled orders).

### POST /api/buyer/watchlist/{productId}
Adds a product to watchlist.

### DELETE /api/buyer/watchlist/{productId}
Removes a product from watchlist.

### GET /api/buyer/watchlist
Returns in-stock products within the watchlist.

## Admin APIs (role: ADMIN)

### GET /api/admin/products
List all products (includes stock quantity and prices).

### POST /api/admin/products
Create a product.

Request body:
```
{
  "description": "Organic Apples",
  "wholesalePrice": 1.00,
  "retailPrice": 2.50,
  "stockQuantity": 10
}
```

### GET /api/admin/products/{productId}
Returns detailed product info for admin.

### PATCH /api/admin/products/{productId}
Updates description, wholesalePrice, retailPrice, stockQuantity.

### GET /api/admin/orders?page=0
Lists orders (page size = 5).

### GET /api/admin/orders/{orderId}
Returns order detail with buyer username and item price snapshots.

### PATCH /api/admin/orders/{orderId}/complete
Marks a PROCESSING order as COMPLETED.

### PATCH /api/admin/orders/{orderId}/cancel
Cancels a PROCESSING order and restores stock.

### GET /api/admin/summary/profit
Returns the most profitable product (completed orders only).

### GET /api/admin/summary/popular
Top 3 most popular products (completed orders only).

### GET /api/admin/summary/total-sold
Total items sold successfully (completed orders only).

## Error Response Shape

All errors are returned as:

```
{
  "error": "NotEnoughInventory",
  "message": "Not enough inventory for product 3",
  "details": null,
  "timestamp": "2025-01-01T10:00:00Z"
}
```

Common statuses:
- 400 ValidationError
- 401 InvalidCredentials
- 403 Forbidden
- 404 NotFound
- 409 Conflict / NotEnoughInventory

## Notes for Frontend

- Store and attach the JWT to all protected endpoints.
- Buyer product views never expose stock quantity.
- Order items store snapshot prices, so historical orders are stable even if product prices change later.
- Order statuses: PROCESSING, COMPLETED, CANCELED.
