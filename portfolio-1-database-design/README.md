# Portfolio 1: Database Design and Modelling

**Case Study:** ShopEase E-Commerce Platform
**Database:** PostgreSQL

---

## Overview

This portfolio covers the complete database design for the ShopEase e-commerce platform. It includes the Entity-Relationship (ER) diagram, relational schema, primary/foreign keys, constraints, and normalisation analysis.

---

## Deliverables

| File | Description |
|------|-------------|
| `er-diagram.png` | Entity-Relationship diagram showing all entities and relationships |
| `schema.sql` | Full PostgreSQL schema with tables, keys, and constraints |
| `normalisation.md` | Normalisation analysis from 1NF through 3NF |

---

## Entities Identified

| Entity | Description |
|--------|-------------|
| `users` | All platform users (customers, vendors, admins) |
| `categories` | Product categories and subcategories |
| `products` | Product listings by vendors |
| `inventory` | Stock levels per product |
| `orders` | Customer orders |
| `order_items` | Individual line items within each order |
| `payments` | Payment transactions linked to orders |
| `deliveries` | Delivery records and status tracking |
| `reviews` | Customer product reviews and ratings |
| `addresses` | Customer shipping addresses |

---

## Relationships Summary

- A **user** can place many **orders** (one-to-many)
- An **order** contains many **order_items** (one-to-many)
- Each **order_item** references one **product** (many-to-one)
- A **product** belongs to one **category** (many-to-one)
- A **product** has one **inventory** record (one-to-one)
- An **order** has one **payment** (one-to-one)
- An **order** has one **delivery** record (one-to-one)
- A **user** can write many **reviews** (one-to-many)
- A **product** can have many **reviews** (one-to-many)
- A **user** can have many **addresses** (one-to-many)

---

## Status
- [x] Case study defined
- [x] Entities identified
- [ ] ER diagram created
- [ ] Schema SQL written
- [ ] Normalisation documented
