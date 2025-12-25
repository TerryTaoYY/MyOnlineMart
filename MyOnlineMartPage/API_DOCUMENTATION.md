# MyOnlineMart API Documentation

Base URL: http://localhost:8080

All endpoints accept/return JSON unless noted. All endpoints require JWT authentication except `/api/auth/**`. Supply:

```
Authorization: Bearer <token>
```

## Authentication

### POST /api/auth/register
Registers a buyer account and returns a JWT.

Request body:
```json
{
  "username": "buyer1",
  "email": "buyer1@example.com",
  "password": "Password123!"
}
```

Response (200):
```json
{
  "token": "...",
  "role": "BUYER",
  "username": "buyer1",
  "userId": 3
}
```

Errors:
- 400 ValidationError when request fields are missing/invalid.
- 409 Conflict when username or email is already in use.

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
- 400 ValidationError when request fields are missing/invalid.
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

Response (200):
```json
{
  "id": 1,
  "description": "Organic Apples",
  "retailPrice": 2.75
}
```

Errors:
- 404 NotFound when the product does not exist or is out of stock.

### POST /api/buyer/orders
Creates an order in PROCESSING status. Deducts stock.

Request body:
```json
{
  "items": [
    {"productId": 1, "quantity": 2},
    {"productId": 2, "quantity": 1}
  ]
}
```

Response (200):
```json
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
- 400 ValidationError when request fields are missing/invalid.
- 400 BadRequest when the order has no items.
- 404 NotFound when a product does not exist.
- 409 NotEnoughInventory when requested quantity exceeds stock.

### GET /api/buyer/orders
Lists orders for the current buyer.

Response (200):
```
[
  {"id": 10, "placedAt": "2025-01-01T10:00:00Z", "status": "PROCESSING"}
]
```

### GET /api/buyer/orders/{orderId}
Returns order details for current buyer only.

Response (200): same shape as create order response.

Errors:
- 403 Forbidden when accessing another buyer's order.
- 404 NotFound when the order does not exist.

### PATCH /api/buyer/orders/{orderId}/cancel
Cancels a PROCESSING order and restores stock.

Response (200):
```
{"orderId": 10, "status": "CANCELED"}
```

Errors:
- 403 Forbidden when canceling another buyer's order.
- 404 NotFound when the order does not exist.
- 409 Conflict when the order is already completed or canceled.

### GET /api/buyer/orders/top/frequent
Top 3 most frequently purchased items (excludes canceled orders).

Response (200):
```
[
  {"productId": 1, "description": "Organic Apples", "totalQuantity": 5}
]
```

### GET /api/buyer/orders/top/recent
Top 3 most recently purchased items (excludes canceled orders).

Response (200):
```
[
  {"productId": 2, "description": "Almond Milk", "lastPurchasedAt": "2025-01-02T08:00:00Z"}
]
```

### POST /api/buyer/watchlist/{productId}
Adds a product to watchlist.

Response (200): no body.

Errors:
- 404 NotFound when the product does not exist.
- 409 Conflict when the product is already in the watchlist.

### DELETE /api/buyer/watchlist/{productId}
Removes a product from watchlist.

Response (200): no body.

Errors:
- 404 NotFound when the product is not in the watchlist.

### GET /api/buyer/watchlist
Returns products within the buyer's watchlist.

Response (200):
```json
[
  { "id": 1, "description": "Organic Apples", "retailPrice": 2.75 }
]
```

## Admin APIs (role: ADMIN)

### GET /api/admin/products
List all products (includes stock quantity and prices).

Response (200):
```
[
  {"id": 1, "description": "Organic Apples", "wholesalePrice": 1.00, "retailPrice": 2.50, "stockQuantity": 10}
]
```

### POST /api/admin/products
Create a product.

Request body:
```json
{
  "description": "Organic Apples",
  "wholesalePrice": 1.00,
  "retailPrice": 2.50,
  "stockQuantity": 10
}
```

Response (200): same shape as admin product detail.
```json
{
  "id": 1,
  "description": "Organic Apples",
  "wholesalePrice": 1.00,
  "retailPrice": 2.50,
  "stockQuantity": 10
}
```

Errors:
- 400 ValidationError when request fields are missing/invalid.

### GET /api/admin/products/{productId}
Returns detailed product info for admin.

Response (200):
```json
{
  "id": 1,
  "description": "Organic Apples",
  "wholesalePrice": 1.00,
  "retailPrice": 2.50,
  "stockQuantity": 10
}
```

Errors:
- 404 NotFound when the product does not exist.

### PATCH /api/admin/products/{productId}
Updates description, wholesalePrice, retailPrice, stockQuantity.

Request fields are optional; only provided fields are updated.

Response (200): same shape as admin product detail.

Errors:
- 400 ValidationError when request fields are invalid.
- 404 NotFound when the product does not exist.

### GET /api/admin/orders?page=0
Lists orders (page size = 5).

Response (200):
```
[
  {"id": 10, "placedAt": "2025-01-01T10:00:00Z", "status": "PROCESSING", "buyerUsername": "buyer1"}
]
```

### GET /api/admin/orders/{orderId}
Returns order detail with buyer username and item price snapshots.

Response (200):
```
{
  "id": 10,
  "placedAt": "2025-01-01T10:00:00Z",
  "status": "PROCESSING",
  "buyerUsername": "buyer1",
  "items": [
    {"productId": 1, "description": "Organic Apples", "quantity": 2, "unitWholesalePrice": 1.00, "unitRetailPrice": 2.50}
  ]
}
```

Errors:
- 404 NotFound when the order does not exist.

### PATCH /api/admin/orders/{orderId}/complete
Marks a PROCESSING order as COMPLETED.

Response (200):
```
{"orderId": 10, "status": "COMPLETED"}
```

Errors:
- 404 NotFound when the order does not exist.
- 409 Conflict when the order is already completed or canceled.

### PATCH /api/admin/orders/{orderId}/cancel
Cancels a PROCESSING order and restores stock.

Response (200):
```
{"orderId": 10, "status": "CANCELED"}
```

Errors:
- 404 NotFound when the order does not exist.
- 409 Conflict when the order is already completed or canceled.

### GET /api/admin/summary/profit
Returns the most profitable product (completed orders only).

Response (200):
```
{"productId": 1, "description": "Organic Apples", "totalProfit": 15.00}
```

Errors:
- 404 NotFound when there are no completed orders yet.

### GET /api/admin/summary/popular
Top 3 most popular products (completed orders only).

Response (200):
```
[
  {"productId": 1, "description": "Organic Apples", "totalQuantity": 20}
]
```

### GET /api/admin/summary/total-sold
Total items sold successfully (completed orders only).

Response (200):
```
{"totalItems": 42}
```

## Error Response Shape

All errors are returned as:

```
{
  "error": "NotEnoughInventory",
  "message": "Not enough inventory for product 3",
  "details": ["items[0].quantity: must be greater than or equal to 1"],
  "timestamp": "2025-01-01T10:00:00Z"
}
```

Common statuses:
- 400 ValidationError
- 400 BadRequest
- 401 InvalidCredentials
- 403 Forbidden
- 404 NotFound
- 409 Conflict
- 409 NotEnoughInventory
- 500 ServerError

## Notes for Frontend

- Store and attach the JWT to all protected endpoints.
- Buyer product views never expose stock quantity.
- Order items store snapshot prices, so historical orders are stable even if product prices change later.
- Order statuses: PROCESSING, COMPLETED, CANCELED.
