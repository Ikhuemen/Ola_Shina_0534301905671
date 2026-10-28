-- ============================================================
-- ShopEase E-Commerce Platform
-- Portfolio 3: Transactions and Concurrency
-- MIT 8103 Advanced Database Systems
-- ============================================================


-- ============================================================
-- EXAMPLE 1: Successful Order Placement (COMMIT)
-- Places an order, deducts inventory, and records payment
-- all as a single atomic transaction
-- ============================================================

BEGIN;

-- Step 1: Insert the order
INSERT INTO orders (customer_id, address_id, status, total_amount)
VALUES (1, 1, 'confirmed', 875.00);

-- Step 2: Get the new order id
-- (In application code this uses RETURNING id; here we use lastval())
-- Step 3: Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (lastval(), 1, 1, 850.00),
       (lastval(), 2, 2, 25.00);

-- Step 4: Deduct stock from inventory
UPDATE inventory SET quantity = quantity - 1, updated_at = NOW()
WHERE product_id = 1;

UPDATE inventory SET quantity = quantity - 2, updated_at = NOW()
WHERE product_id = 2;

-- Step 5: Record the payment
INSERT INTO payments (order_id, amount, method, status, paid_at)
VALUES (lastval(), 875.00, 'card', 'successful', NOW());

COMMIT;
-- All steps succeed together or none at all


-- ============================================================
-- EXAMPLE 2: Failed Payment — ROLLBACK
-- Simulates a payment failure rolling back the entire order
-- ============================================================

BEGIN;

INSERT INTO orders (customer_id, address_id, status, total_amount)
VALUES (2, 2, 'pending', 600.00);

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (lastval(), 3, 1, 600.00);

UPDATE inventory SET quantity = quantity - 1, updated_at = NOW()
WHERE product_id = 3;

-- Payment gateway returns failure — roll back everything
ROLLBACK;
-- Order, order_items, and inventory deduction are all undone


-- ============================================================
-- EXAMPLE 3: SAVEPOINT — Partial Rollback
-- Attempts to apply a discount but rolls back only that step
-- if the discount is invalid, keeping the order intact
-- ============================================================

BEGIN;

INSERT INTO orders (customer_id, address_id, status, total_amount)
VALUES (1, 1, 'confirmed', 850.00);

SAVEPOINT after_order;

-- Attempt to apply a 10% discount (simulated as an update)
UPDATE orders SET total_amount = total_amount * 0.90
WHERE id = lastval();

-- Discount validation fails (e.g. customer not eligible)
-- Roll back only the discount, keep the order
ROLLBACK TO SAVEPOINT after_order;

COMMIT;
-- Order is committed without the discount


-- ============================================================
-- EXAMPLE 4: Isolation Level — READ COMMITTED (default)
-- Prevents dirty reads: Transaction B cannot read uncommitted
-- changes made by Transaction A
-- ============================================================

-- SESSION A (run first, do not commit yet):
BEGIN;
UPDATE inventory SET quantity = 0 WHERE product_id = 1;
-- Do NOT commit yet — simulating in-flight update

-- SESSION B (run concurrently in a separate connection):
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
SELECT quantity FROM inventory WHERE product_id = 1;
-- Returns original quantity — cannot see Session A's uncommitted change
COMMIT;

-- SESSION A:
COMMIT; -- Now Session B would see the update on next read


-- ============================================================
-- EXAMPLE 5: Isolation Level — REPEATABLE READ
-- Prevents non-repeatable reads: once a row is read in a
-- transaction, re-reading it returns the same value even if
-- another transaction commits a change in between
-- ============================================================

-- SESSION A:
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;
SELECT quantity FROM inventory WHERE product_id = 2;
-- Returns 50 (example value)

-- SESSION B (commits a change between Session A's two reads):
BEGIN;
UPDATE inventory SET quantity = 30 WHERE product_id = 2;
COMMIT;

-- SESSION A (re-reads the same row):
SELECT quantity FROM inventory WHERE product_id = 2;
-- Still returns 50 — repeatable read guarantees consistency
COMMIT;


-- ============================================================
-- EXAMPLE 6: Deadlock Demonstration and Prevention
-- Two transactions lock rows in opposite order — PostgreSQL
-- detects the deadlock and aborts one transaction
-- ============================================================

-- SESSION A:
BEGIN;
UPDATE inventory SET quantity = quantity - 1 WHERE product_id = 1;
-- Holds lock on product_id = 1, now tries to lock product_id = 2

-- SESSION B (runs concurrently):
BEGIN;
UPDATE inventory SET quantity = quantity - 1 WHERE product_id = 2;
-- Holds lock on product_id = 2, now tries to lock product_id = 1
-- DEADLOCK — PostgreSQL detects cycle and rolls back one session

-- Prevention: Always acquire locks in a consistent order
-- Both sessions should lock product_id = 1 before product_id = 2
UPDATE inventory SET quantity = quantity - 1 WHERE product_id IN (1, 2)
ORDER BY product_id; -- consistent ordering prevents deadlock
