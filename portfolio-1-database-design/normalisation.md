# Normalisation Analysis
**ShopEase E-Commerce Platform**
**MIT 8103 Advanced Database Systems — Portfolio 1**

---

## What is Normalisation?

Normalisation is the process of organising a relational database to reduce data redundancy and improve data integrity. It involves decomposing tables into smaller, well-structured relations and applying a series of rules called Normal Forms.

---

## Starting Point: Unnormalised Data (UNF)

Before normalisation, consider a flat record of an order as it might appear in a spreadsheet:

| order_id | customer_name | customer_email | product_names | product_prices | quantities | payment_method | delivery_status | address |
|----------|--------------|----------------|---------------|----------------|------------|----------------|-----------------|---------|
| 1001 | John Doe | john@email.com | Laptop, Mouse | 850.00, 25.00 | 1, 2 | card | delivered | 12 Oak St, Lagos |
| 1002 | Jane Smith | jane@email.com | Phone | 600.00 | 1 | wallet | in_transit | 5 Park Ave, Abuja |

**Problems identified:**
- Multiple values in single columns (`product_names`, `product_prices`, `quantities`)
- Customer details repeated across orders
- No clear primary key structure

---

## First Normal Form (1NF)

**Rule:** Every column must hold atomic (indivisible) values. No repeating groups or arrays.

**Applied to ShopEase:**

Split multi-valued product columns into separate rows using an `order_items` table:

**orders table:**
| order_id | customer_name | customer_email | payment_method | delivery_status | address |
|----------|--------------|----------------|----------------|-----------------|---------|
| 1001 | John Doe | john@email.com | card | delivered | 12 Oak St, Lagos |
| 1002 | Jane Smith | jane@email.com | wallet | in_transit | 5 Park Ave, Abuja |

**order_items table:**
| order_id | product_name | price | quantity |
|----------|-------------|-------|----------|
| 1001 | Laptop | 850.00 | 1 |
| 1001 | Mouse | 25.00 | 2 |
| 1002 | Phone | 600.00 | 1 |

**Result:** All columns now hold atomic values. The schema satisfies 1NF.

---

## Second Normal Form (2NF)

**Rule:** Must be in 1NF, and every non-key column must depend on the **whole** primary key (no partial dependencies).

**Problem identified in 1NF:**

In `order_items`, a composite key of `(order_id, product_name)` is used. But `price` depends only on `product_name`, not on `order_id`. This is a **partial dependency**.

**Applied to ShopEase:**

Extract products into their own table:

**products table:**
| product_id | product_name | price | category |
|------------|-------------|-------|----------|
| 1 | Laptop | 850.00 | Electronics |
| 2 | Mouse | 25.00 | Electronics |
| 3 | Phone | 600.00 | Electronics |

**order_items table (revised):**
| order_id | product_id | quantity | unit_price |
|----------|------------|----------|------------|
| 1001 | 1 | 1 | 850.00 |
| 1001 | 2 | 2 | 25.00 |
| 1002 | 3 | 1 | 600.00 |

**Result:** No partial dependencies remain. The schema satisfies 2NF.

---

## Third Normal Form (3NF)

**Rule:** Must be in 2NF, and no non-key column must depend on another non-key column (no transitive dependencies).

**Problem identified in 2NF:**

In the `orders` table, `customer_email` and `address` depend on `customer_name`, not directly on `order_id`. Similarly, `delivery_status` depends on the order but belongs to a separate concern. These are **transitive dependencies**.

**Applied to ShopEase:**

Extract customers, addresses, payments, and deliveries into their own tables:

**users table:** `id, full_name, email, password_hash, role`

**addresses table:** `id, user_id, street, city, state, country`

**orders table:** `id, customer_id, address_id, status, total_amount, created_at`

**payments table:** `id, order_id, amount, method, status, paid_at`

**deliveries table:** `id, order_id, agent_id, status, dispatched_at, delivered_at`

**Result:** Every non-key column depends only on the primary key of its own table. No transitive dependencies remain. The schema satisfies 3NF.

---

## Boyce-Codd Normal Form (BCNF)

**Rule:** A stricter version of 3NF. For every functional dependency X → Y, X must be a superkey.

**Applied to ShopEase:**

The `reviews` table has a `UNIQUE(user_id, product_id)` constraint, meaning the combination of user and product functionally determines the review. Since `(user_id, product_id)` is a candidate key (superkey), this satisfies BCNF.

All other tables in the ShopEase schema also satisfy BCNF, as their only functional dependencies are from primary keys to non-key attributes.

---

## Summary

| Normal Form | Requirement | Status |
|-------------|-------------|--------|
| 1NF | Atomic values, no repeating groups | Satisfied |
| 2NF | No partial dependencies | Satisfied |
| 3NF | No transitive dependencies | Satisfied |
| BCNF | Every determinant is a superkey | Satisfied |

The final ShopEase schema is fully normalised to BCNF, ensuring minimal redundancy, strong data integrity, and a clean relational structure across all ten tables.
