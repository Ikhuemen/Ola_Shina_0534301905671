# Portfolio 3: Transactions and Concurrency

**Case Study:** ShopEase E-Commerce Platform
**Database:** PostgreSQL

---

## Overview

This portfolio demonstrates transaction management and concurrency control in the ShopEase database. It covers atomic transactions, rollback on failure, savepoints, isolation levels, and deadlock prevention — all applied to realistic e-commerce scenarios.

---

## Deliverables

| File | Description |
|------|-------------|
| `transactions.sql` | 6 transaction examples covering COMMIT, ROLLBACK, SAVEPOINT, isolation levels, and deadlocks |
| `screenshots/` | Output screenshots from PostgreSQL showing transaction results |

---

## Transaction Examples

### Example 1: Successful Order Placement (COMMIT)
**Scenario:** A customer places an order for a Laptop and a Mouse.

The transaction atomically:
1. Inserts the order record
2. Inserts order line items
3. Deducts stock from inventory
4. Records the payment

If all steps succeed, `COMMIT` makes all changes permanent. If any step fails, the entire transaction is automatically rolled back — the database never ends up in a half-written state.

---

### Example 2: Failed Payment — ROLLBACK
**Scenario:** A customer attempts to order a Phone, but the payment gateway returns a failure.

`ROLLBACK` undoes the order insertion, order items, and inventory deduction — as if the transaction never happened. This ensures inventory is never decremented for an unpaid order.

---

### Example 3: SAVEPOINT — Partial Rollback
**Scenario:** An order is placed, then a discount is attempted but fails validation.

`SAVEPOINT` marks a point within the transaction. `ROLLBACK TO SAVEPOINT` undoes only the discount step, while the order itself is preserved and committed. This allows fine-grained control within a single transaction.

---

### Example 4: READ COMMITTED Isolation Level
**Scenario:** One session updates inventory but has not yet committed. A second session reads the same row.

With `READ COMMITTED` (PostgreSQL's default), Session B cannot see Session A's uncommitted change — **dirty reads are prevented**. Session B always reads the last committed value.

---

### Example 5: REPEATABLE READ Isolation Level
**Scenario:** Session A reads inventory twice within the same transaction. Between reads, Session B commits an update to the same row.

With `REPEATABLE READ`, Session A's second read returns the same value as the first — the snapshot is frozen at transaction start. This prevents **non-repeatable reads**, which could cause inconsistent calculations (e.g. double-checking stock availability).

---

### Example 6: Deadlock Demonstration and Prevention
**Scenario:** Session A locks product 1 and waits for product 2. Session B locks product 2 and waits for product 1 — a circular wait (deadlock).

PostgreSQL detects the cycle and automatically aborts one of the transactions with:
```
ERROR: deadlock detected
DETAIL: Process X waits for ShareLock on transaction Y; blocked by process Z.
```

**Prevention strategy:** Always acquire locks in a consistent order (e.g. ascending `product_id`). Using `ORDER BY product_id` in the UPDATE statement ensures both sessions lock rows in the same sequence, eliminating the circular dependency.

---

## Isolation Levels Summary

| Level | Dirty Read | Non-Repeatable Read | Phantom Read |
|-------|-----------|---------------------|--------------|
| READ UNCOMMITTED | Possible | Possible | Possible |
| READ COMMITTED | Prevented | Possible | Possible |
| REPEATABLE READ | Prevented | Prevented | Possible |
| SERIALIZABLE | Prevented | Prevented | Prevented |

PostgreSQL defaults to **READ COMMITTED**. ShopEase uses **REPEATABLE READ** for checkout and payment flows to prevent stock inconsistencies under concurrent load.

---

## Concurrency Issues Addressed

| Issue | Description | Solution Applied |
|-------|-------------|-----------------|
| Dirty Read | Reading uncommitted data from another transaction | READ COMMITTED isolation |
| Non-Repeatable Read | Re-reading a row gives different results | REPEATABLE READ isolation |
| Lost Update | Two transactions overwrite each other's changes | Row-level locking via UPDATE |
| Deadlock | Circular lock dependency between transactions | Consistent lock ordering |

---

## Status
- [x] COMMIT transaction example
- [x] ROLLBACK transaction example
- [x] SAVEPOINT partial rollback example
- [x] READ COMMITTED isolation level demonstrated
- [x] REPEATABLE READ isolation level demonstrated
- [x] Deadlock demonstration and prevention
