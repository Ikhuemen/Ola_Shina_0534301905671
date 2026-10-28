# Portfolio 2: Query Processing and Optimisation

**Case Study:** ShopEase E-Commerce Platform
**Database:** PostgreSQL

---

## Overview

This portfolio demonstrates SQL query design, execution plan analysis, index creation, and performance optimisation for the ShopEase e-commerce database built in Portfolio 1.

---

## Deliverables

| File | Description |
|------|-------------|
| `queries.sql` | 8 core SQL queries covering key business operations |
| `indexes.sql` | Index creation scripts with EXPLAIN ANALYZE before and after |
| `screenshots/` | Execution plan screenshots showing performance improvement |

---

## Queries Implemented

| Query | Description |
|-------|-------------|
| Q1 | Products by category with stock levels |
| Q2 | All orders for a customer with payment and delivery status |
| Q3 | Top 5 best-selling products by quantity |
| Q4 | Total revenue per vendor |
| Q5 | Low stock products (quantity < 10) |
| Q6 | Average product rating per category |
| Q7 | Orders placed in the last 30 days |
| Q8 | Customers who have never placed an order |

---

## Indexes Created

| Index | Table | Column(s) | Purpose |
|-------|-------|-----------|---------|
| idx_products_vendor_id | products | vendor_id | Vendor product lookups |
| idx_products_category_id | products | category_id | Category filtering (Q1) |
| idx_orders_customer_id | orders | customer_id | Customer order history (Q2) |
| idx_orders_status | orders | status | Status-based filtering |
| idx_orders_created_at | orders | created_at | Date range queries (Q7) |
| idx_order_items_order_id | order_items | order_id | Join optimisation (Q3, Q4) |
| idx_order_items_product_id | order_items | product_id | Product join optimisation |
| idx_inventory_quantity | inventory | quantity | Low stock queries (Q5) |
| idx_reviews_product_id | reviews | product_id | Rating aggregation (Q6) |
| idx_categories_name | categories | name | Category name lookup (Q1) |

---

## Performance Analysis

### Before Indexing
Without indexes, PostgreSQL performs a **Sequential Scan (Seq Scan)** on large tables — reading every row to find matches. This becomes increasingly expensive as data grows.

Example from `EXPLAIN ANALYZE` on Q1 before indexes:
```
Seq Scan on products  (cost=0.00..35.50 rows=10 width=72)
  Filter: (category_id = ...)
```

### After Indexing
With indexes in place, PostgreSQL switches to an **Index Scan** — jumping directly to matching rows without reading the entire table.

Example from `EXPLAIN ANALYZE` on Q1 after indexes:
```
Index Scan using idx_products_category_id on products  (cost=0.15..8.17 rows=10 width=72)
  Index Cond: (category_id = ...)
```

### Key Observations
- Index scans significantly reduce cost estimates, especially on large datasets
- Foreign key columns (vendor_id, customer_id, order_id, product_id) benefit most from indexing as they appear in JOIN conditions
- The `created_at` index on orders allows efficient date range filtering without full table scans
- Over-indexing can slow down INSERT/UPDATE operations — only high-traffic columns were indexed

---

## How to Run

1. Ensure the schema from Portfolio 1 (`schema.sql`) has been executed first
2. Populate the database with sample data
3. Run `queries.sql` to execute and review all 8 queries
4. Run `indexes.sql` step by step — first the EXPLAIN ANALYZE before section, then create indexes, then re-run EXPLAIN ANALYZE to compare plans

---

## Status
- [x] SQL queries written
- [x] Indexes defined
- [x] EXPLAIN ANALYZE before/after documented
- [x] Performance analysis completed
