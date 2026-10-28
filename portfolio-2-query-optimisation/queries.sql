-- ============================================================
-- ShopEase E-Commerce Platform
-- Portfolio 2: Query Processing and Optimisation
-- Core SQL Queries
-- MIT 8103 Advanced Database Systems
-- ============================================================

-- ------------------------------------------------------------
-- Q1: Retrieve all products in a given category with stock info
-- ------------------------------------------------------------
SELECT
    p.id,
    p.name,
    p.price,
    c.name AS category,
    i.quantity AS stock
FROM products p
JOIN categories c ON c.id = p.category_id
JOIN inventory i ON i.product_id = p.id
WHERE c.name = 'Electronics'
ORDER BY p.price DESC;

-- ------------------------------------------------------------
-- Q2: Get all orders for a specific customer with order status
-- ------------------------------------------------------------
SELECT
    o.id AS order_id,
    o.created_at,
    o.status,
    o.total_amount,
    pay.status AS payment_status,
    d.status AS delivery_status
FROM orders o
LEFT JOIN payments pay ON pay.order_id = o.id
LEFT JOIN deliveries d ON d.order_id = o.id
WHERE o.customer_id = 1
ORDER BY o.created_at DESC;

-- ------------------------------------------------------------
-- Q3: Top 5 best-selling products by total quantity sold
-- ------------------------------------------------------------
SELECT
    p.id,
    p.name,
    SUM(oi.quantity) AS total_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN products p ON p.id = oi.product_id
JOIN orders o ON o.id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY p.id, p.name
ORDER BY total_sold DESC
LIMIT 5;

-- ------------------------------------------------------------
-- Q4: Calculate total revenue per vendor
-- ------------------------------------------------------------
SELECT
    u.id AS vendor_id,
    u.full_name AS vendor_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN products p ON p.id = oi.product_id
JOIN users u ON u.id = p.vendor_id
JOIN orders o ON o.id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY u.id, u.full_name
ORDER BY total_revenue DESC;

-- ------------------------------------------------------------
-- Q5: Find products with low stock (quantity < 10)
-- ------------------------------------------------------------
SELECT
    p.id,
    p.name,
    p.price,
    i.quantity AS stock,
    u.full_name AS vendor
FROM inventory i
JOIN products p ON p.id = i.product_id
JOIN users u ON u.id = p.vendor_id
WHERE i.quantity < 10
ORDER BY i.quantity ASC;

-- ------------------------------------------------------------
-- Q6: Average product rating per category
-- ------------------------------------------------------------
SELECT
    c.name AS category,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.id) AS total_reviews
FROM reviews r
JOIN products p ON p.id = r.product_id
JOIN categories c ON c.id = p.category_id
GROUP BY c.name
ORDER BY avg_rating DESC;

-- ------------------------------------------------------------
-- Q7: Orders placed in the last 30 days with full details
-- ------------------------------------------------------------
SELECT
    o.id AS order_id,
    u.full_name AS customer,
    o.total_amount,
    o.status,
    o.created_at
FROM orders o
JOIN users u ON u.id = o.customer_id
WHERE o.created_at >= NOW() - INTERVAL '30 days'
ORDER BY o.created_at DESC;

-- ------------------------------------------------------------
-- Q8: Customers who have never placed an order (LEFT JOIN)
-- ------------------------------------------------------------
SELECT
    u.id,
    u.full_name,
    u.email
FROM users u
LEFT JOIN orders o ON o.customer_id = u.id
WHERE u.role = 'customer'
  AND o.id IS NULL;
