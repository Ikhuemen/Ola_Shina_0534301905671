-- ShopEase — Transaction and Concurrency Examples


-- Example 1: Successful order placement (COMMIT)
-- Order, items, inventory deduction, and payment all succeed atomically

BEGIN;

INSERT INTO orders (customer_id, address_id, status, total_amount)
VALUES (1, 1, 'confirmed', 875.00);

-- lastval() retrieves the order id just inserted
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (lastval(), 1, 1, 850.00),
       (lastval(), 2, 2, 25.00);

UPDATE inventory SET quantity = quantity - 1, updated_at = NOW()
WHERE product_id = 1;

UPDATE inventory SET quantity = quantity - 2, updated_at = NOW()
WHERE product_id = 2;

INSERT INTO payments (order_id, amount, method, status, paid_at)
VALUES (lastval(), 875.00, 'card', 'successful', NOW());

COMMIT;


-- Example 2: Failed payment — ROLLBACK
-- Order and inventory changes are undone as if nothing happened

BEGIN;

INSERT INTO orders (customer_id, address_id, status, total_amount)
VALUES (2, 2, 'pending', 600.00);

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (lastval(), 3, 1, 600.00);

UPDATE inventory SET quantity = quantity - 1, updated_at = NOW()
WHERE product_id = 3;

ROLLBACK;


-- Example 3: SAVEPOINT — partial rollback
-- Order is kept; only the discount step is rolled back

BEGIN;

INSERT INTO orders (customer_id, address_id, status, total_amount)
VALUES (1, 1, 'confirmed', 850.00);

SAVEPOINT after_order;

UPDATE orders SET total_amount = total_amount * 0.90
WHERE id = lastval();

-- Discount validation fails — undo only this step
ROLLBACK TO SAVEPOINT after_order;

COMMIT;


-- Example 4: READ COMMITTED isolation (PostgreSQL default)
-- Session B cannot read Session A's uncommitted changes

-- SESSION A:
BEGIN;
UPDATE inventory SET quantity = 0 WHERE product_id = 1;

-- SESSION B (separate connection):
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
SELECT quantity FROM inventory WHERE product_id = 1;
-- Returns original value — dirty read is prevented
COMMIT;

-- SESSION A:
COMMIT;


-- Example 5: REPEATABLE READ isolation
-- Session A reads the same value twice even after Session B commits a change

-- SESSION A:
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;
SELECT quantity FROM inventory WHERE product_id = 2;
-- Returns 50

-- SESSION B:
BEGIN;
UPDATE inventory SET quantity = 30 WHERE product_id = 2;
COMMIT;

-- SESSION A:
SELECT quantity FROM inventory WHERE product_id = 2;
-- Still returns 50 — snapshot is frozen at transaction start
COMMIT;


-- Example 6: Deadlock and prevention
-- Sessions A and B lock rows in opposite order — PostgreSQL detects and aborts one

-- SESSION A:
BEGIN;
UPDATE inventory SET quantity = quantity - 1 WHERE product_id = 1;
-- waiting for product_id = 2 ...

-- SESSION B:
BEGIN;
UPDATE inventory SET quantity = quantity - 1 WHERE product_id = 2;
-- waiting for product_id = 1 — DEADLOCK detected, one session is aborted

-- Prevention: lock rows in consistent order using ORDER BY
UPDATE inventory SET quantity = quantity - 1
WHERE product_id IN (1, 2)
ORDER BY product_id;
