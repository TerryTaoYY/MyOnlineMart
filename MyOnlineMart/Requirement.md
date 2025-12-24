Online Shopping App Requirements

## Create a Shopping application which supports the following:

### High Level Design(HLD):

- Use Spring Boot, Hibernate (HQL, Criteria), PostgreSQL, Spring Security + JWT , Spring AOP , Spring Validation to develop the backend.
    - You CAN NOT use JDBC/JdbcTemplate, JPA repository, CRUD repository, or the native query.
    - At least one of the DAO functions needs to be implemented with Criteria.
    - Using Spring AOP to handle all exception throws in the controller and return HTTP response
- Use Angular to develop the frontend.
- RESTful application required following a layered architecture: RestController, service, repository.
- Use Postman to present your project by calling your RESTful endpoints.
- All required functionalities should be implemented.
- If you are using a version control tool such as GitHub, please make your repository PRIVATE!!!

The retailer tycoon, Super Duper Mart™ , requires your assistance in setting up their online shopping website. The following is the requirement they sent over. Based on these requirements, please come up with a RESTful application that is equipped with the necessary endpoints to return the needed information for each of their requirements.

---

## User (Buyer)

The users are able to shop for different products from Super Duper Mart™.

### 1. Registration [POST]

a. Before being able to purchase products, a user has to first register.

i. Your application should prevent registration using the same username and email.
ii. Only username, email and password are required to register an account.
iii. Password should be encrypted (Bonus)

### 2. Login [POST]

a. If the user has entered the correct credentials, they may proceed to the corresponding page based on their authorities.

b. If the user has entered incorrect credentials, a custom named exception ‘InvalidCredentialsException’ should be thrown and handled by the Exception handler. The message the user will get is: “Incorrect credentials, please try again.”

### 3. Home Page

a. The user is able to view all of the products. An out of stock product should NOT be shown to the user. [GET]

b. When a user clicks on one product, the user should be redirected to the detail page of that product, including the description and price (retail_price) of the product. (The user should NOT be able to see the actual quantity of any items).[GET]

c. After purchasing the product, the user should be able to view order details including, order placement time and order status which is Processing, Completed or Canceled. [GET]

### 4. Purchasing

a. The user should be able to purchase listing items with a specified quantity by creating a “Processing” order. After a user places an order, the item’s stock should be deducted accordingly. [POST]

i. The user should be able to purchase multiple different items within a single order.

b. If the quantity of an item that the user is purchasing is greater than the item’s stock, throw a custom exception named ‘NotEnoughInventoryException’ using Exception Handler and the order should not be placed.

c. The user should be able to cancel an order by updating the status from “Processing” to “Canceled”. If so, the item’s stock should be incremented accordingly to offset the auto-deduction that took place when the order is first placed. However, a “Completed” order cannot be changed to “Canceled” .[PATCH]

### 5.Product Watchlist

a. The user can add/remove products to/from their watchlist.

i. The user should not be able to add a product that is already on the watchlist [POST]
ii. The user should not be able to remove a product that is not on the watchlist [DELETE]

b. The user can view all in stock products within their watchlist. [GET]

i. When viewing the watchlist, products which are out of stock will not be shown to the user.

### 6. Summary

a. The user should be able to view all their orders. [GET]

i. Note that the wholesale_price and retail_price of a product can be adjusted by the seller, implement something to prevent the adjustments from affecting previous orders.

b. The user can then click and look into any one specific order created by them, completed with the items included in that order. [GET]

c. The user should be able to view their top 3 most frequently purchased items. (excluding canceled order, use item ID as tie breaker) [GET]

d. The user can also view their top 3 most recently purchased items. (excluding canceled order, use item id as tie breaker) [GET]

---

## Admin (Seller)

The seller, Super Duper Mart™, is able to list different products to sell. There is one and ONLY one seller, thus no need to keep user_id foreign keys in the product table.

### 1. Home Page

a. The seller should be able to view a dashboard, consisting of the following:
i. Order information, with details of order placed time, users who placed the order and the order status (Processing, Completed, Canceled).[GET]
1. A page should only have 5 orders (Bonus)
2. The seller can click and see information regarding any single order, completed with the items involved in the order.
ii. Listing information, the current products that are listed to sell. When the seller clicks on one product, the seller should be redirected to the detail page of that product, including the description, wholesale_price, retail_price and stock’s quantity of the product; the seller should be able to modify the wholesale_price, retail_price, description and quantity of a product. [GET]

### 2. Listing

a. The seller should be able to add products. A product has fields including description, wholesale_price, retail_price and stock’s quantity. [POST]

i. The wholesale price is the price which the seller paid for the product.

ii. The retail price is the price which customers pay for the product.

### 3. Selling

a. When one product is sold, the quantity of that product should be deducted accordingly. And such quantity should be reflected on the dashboard.

### 4. Order

a. The seller should be able to complete a “Processing” order by updating its status to “Completed”. [PATCH]

b. The seller should also be able to cancel an order for some reasons, such as that the product is sold out locally, by updating the order status to “Canceled”. If so, the item’s stock should be incremented accordingly to offset the auto-deduction that took place when the order is first placed. However, a “Canceled” order cannot be completed, nor can a “Completed” order be canceled. [PATCH]

### 5. Summary

a. The seller can see which product brings the most profit. [GET]

i. The profit is calculated as (retail price - wholesale price).

ii. Note: This should address situations where the seller alters either the wholesale_price or retail_price, causing a discrepancy when comparing between the past orders and the current updated product details.

iii. This should not include “Processing” and “Canceled” orders.

b. The seller can see which 3 products are the most popular/sold (excluding canceled and ongoing order). [GET]

c. The seller can also see the amount of total items sold successfully (excluding canceled and ongoing order). [GET]

### 6.Additional Features (Bonus)

a. This part would be evaluated by your creativity and completeness of the design. Be creative and think outside of the box :) if you have time

---

## Spring Validation

Using Spring Validation to validate the request in at least one POST request.

---

## Security

Protect your application endpoints using Spring Security + JWT :

### 1. Authentication:

Guests cannot access any endpoints other than for login or registration usage.

### 2.Authorization:

A user with the corresponding authorities can access certain pages that they are granted access to.

a. They should not be able to access information that they don’t have access to:

i. Any of seller’s functionality
ii. Any of other user’s order information
iii. Any other relevant information

---

## Exception Handling

1. Your application must not crash during the presentation. Therefore, if an exception occurs, you must handle it with Spring AOP and display the exception as a message to help yourself and others debug.