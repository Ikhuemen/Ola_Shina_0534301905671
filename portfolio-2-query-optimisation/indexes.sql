-- ShopEase — Index Creation and EXPLAIN ANALYZE Comparison

-- Step 1: Baseline query plans before indexes

EXPLAIN ANALYZE
SELECT p.id, p.name, p.price, c.name AS category, i.quantity AS stock
FROM products p
JOIN categories c ON c.id = p.category_id
JOIN inventory i ON i.product_id = p.id
WHERE c.name = 'Electronics'
ORDER BY p.price DESC;

EXPLAIN ANALYZE
SELECT p.id, p.name, SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN products p ON p.id = oi.product_id
JOIN orders o ON o.id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY p.id, p.name
ORDER BY total_sold DESC
LIMIT 5;


-- Step 2: Create indexes

CREATE INDEX IF NOT EXISTS idx_products_vendor_id     ON products(vendor_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id   ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id     ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status          ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at      ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id   ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_quantity      ON inventory(quantity);
CREATE INDEX IF NOT EXISTS idx_reviews_product_id     ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_categories_name        ON categories(name);


-- Step 3: Re-run same queries to compare plans

EXPLAIN ANALYZE
SELECT p.id, p.name, p.price, c.name AS category, i.quantity AS stock
FROM products p
JOIN categories c ON c.id = p.category_id
JOIN inventory i ON i.product_id = p.id
WHERE c.name = 'Electronics'
ORDER BY p.price DESC;

EXPLAIN ANALYZE
SELECT p.id, p.name, SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN products p ON p.id = oi.product_id
JOIN orders o ON o.id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY p.id, p.name
ORDER BY total_sold DESC
LIMIT 5;
