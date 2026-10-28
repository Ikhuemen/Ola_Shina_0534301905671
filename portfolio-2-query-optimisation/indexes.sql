-- ============================================================
-- ShopEase E-Commerce Platform
-- Portfolio 2: Query Processing and Optimisation
-- Index Creation and Performance Optimisation
-- MIT 8103 Advanced Database Systems
-- ============================================================

-- ============================================================
-- STEP 1: Baseline — Run EXPLAIN ANALYZE before indexes
-- ============================================================

-- Check query plan for Q1 (products by category) — no index yet
EXPLAIN ANALYZE
SELECT p.id, p.name, p.price, c.name AS category, i.quantity AS stock
FROM products p
JOIN categories c ON c.id = p.category_id
JOIN inventory i ON i.product_id = p.id
WHERE c.name = 'Electronics'
ORDER BY p.price DESC;

-- Check query plan for Q3 (top selling products) — no index yet
EXPLAIN ANALYZE
SELECT p.id, p.name, SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN products p ON p.id = oi.product_id
JOIN orders o ON o.id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY p.id, p.name
ORDER BY total_sold DESC
LIMIT 5;


-- ============================================================
-- STEP 2: Create indexes on high-traffic columns
-- ============================================================

-- Index on products.vendor_id — speeds up vendor product lookups
CREATE INDEX IF NOT EXISTS idx_products_vendor_id
    ON products(vendor_id);

-- Index on products.category_id — speeds up category filtering (Q1)
CREATE INDEX IF NOT EXISTS idx_products_category_id
    ON products(category_id);

-- Index on orders.customer_id — speeds up order history lookup (Q2)
CREATE INDEX IF NOT EXISTS idx_orders_customer_id
    ON orders(customer_id);

-- Index on orders.status — speeds up filtering by order status
CREATE INDEX IF NOT EXISTS idx_orders_status
    ON orders(status);

-- Index on orders.created_at — speeds up date range queries (Q7)
CREATE INDEX IF NOT EXISTS idx_orders_created_at
    ON orders(created_at);

-- Index on order_items.order_id — speeds up join with orders (Q3, Q4)
CREATE INDEX IF NOT EXISTS idx_order_items_order_id
    ON order_items(order_id);

-- Index on order_items.product_id — speeds up join with products
CREATE INDEX IF NOT EXISTS idx_order_items_product_id
    ON order_items(product_id);

-- Index on inventory.quantity — speeds up low stock queries (Q5)
CREATE INDEX IF NOT EXISTS idx_inventory_quantity
    ON inventory(quantity);

-- Index on reviews.product_id — speeds up average rating queries (Q6)
CREATE INDEX IF NOT EXISTS idx_reviews_product_id
    ON reviews(product_id);

-- Index on categories.name — speeds up category name lookup (Q1)
CREATE INDEX IF NOT EXISTS idx_categories_name
    ON categories(name);


-- ============================================================
-- STEP 3: After indexes — Run EXPLAIN ANALYZE again to compare
-- ============================================================

-- Re-run Q1 after index — expect Index Scan instead of Seq Scan
EXPLAIN ANALYZE
SELECT p.id, p.name, p.price, c.name AS category, i.quantity AS stock
FROM products p
JOIN categories c ON c.id = p.category_id
JOIN inventory i ON i.product_id = p.id
WHERE c.name = 'Electronics'
ORDER BY p.price DESC;

-- Re-run Q3 after index — expect faster aggregation
EXPLAIN ANALYZE
SELECT p.id, p.name, SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN products p ON p.id = oi.product_id
JOIN orders o ON o.id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY p.id, p.name
ORDER BY total_sold DESC
LIMIT 5;
