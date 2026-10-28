# Portfolio 4: NoSQL and Advanced Data Models

**Case Study:** ShopEase E-Commerce Platform
**NoSQL Database:** MongoDB (Document Store)

---

## Overview

This portfolio re-models the ShopEase e-commerce platform using MongoDB, a document-oriented NoSQL database. It demonstrates how the relational schema from Portfolio 1 translates into a document model, explains the design decisions, and evaluates where MongoDB is suitable — and where it is not.

---

## Deliverables

| File | Description |
|------|-------------|
| `nosql-model.js` | MongoDB shell script with collections, documents, queries, and indexes |
| `screenshots/` | Screenshots of MongoDB Atlas Data Explorer or mongosh output |

---

## NoSQL Model: Collections

The ShopEase MongoDB model uses **4 collections** compared to 10 relational tables in Portfolio 1.

### 1. `users`
Stores customer, vendor, admin, and delivery agent profiles. The default shipping address is **embedded** directly in the user document — common reads fetch user + address in one operation.

### 2. `products`
Each product document includes the category name and current stock quantity as **embedded fields**. This denormalises the data intentionally — product listings are read far more often than they are written, so the read performance gain outweighs the cost of updating embedded fields on stock changes.

### 3. `orders`
The order document **embeds the full items array**, payment details, and delivery status. A single document fetch returns the complete order with no joins. This is the most important design decision — order reads (customer checking order history) greatly outnumber order writes.

### 4. `reviews`
Reviews are kept in a **separate collection** rather than embedded in product documents. Embedding reviews in products would create unbounded array growth (a product could have thousands of reviews), making document size unpredictable and updates expensive.

---

## Relational vs Document: Design Decisions

| Aspect | Relational (Portfolio 1) | MongoDB (Portfolio 4) |
|--------|--------------------------|----------------------|
| Order + items | 2 tables (orders, order_items) joined | 1 document with embedded items array |
| Product + stock | 2 tables (products, inventory) joined | 1 document with embedded stock field |
| User + address | 2 tables (users, addresses) joined | 1 document with embedded default_address |
| Reviews | Separate table with FK | Separate collection (avoids unbounded arrays) |
| Categories | Separate table with self-join | Stored as a string field in product document |

---

## Why MongoDB Suits E-Commerce (Partially)

### Strengths
- **Flexible schema:** New product attributes (colour, size, weight) can be added per document without schema migrations
- **Embedded documents:** Order with all its items fetched in a single read — no JOIN overhead
- **Horizontal scaling:** MongoDB supports sharding across multiple servers natively
- **Array operators:** Querying within embedded arrays (`$elemMatch`, `$in`) is powerful for product tags and order items
- **Read performance:** Denormalised documents make read-heavy workloads (product browsing, order tracking) very fast

### Limitations
- **No native transactions across collections** (multi-document ACID transactions are possible in MongoDB 4.x+ but more complex than PostgreSQL)
- **Data duplication:** Product name and price are stored in order items — if a product is updated, historical orders still show the old name (this is actually desirable for order history accuracy)
- **Aggregation complexity:** Revenue reports and cross-collection analytics are more complex than SQL GROUP BY queries
- **No enforced foreign keys:** Referential integrity must be enforced at the application layer

---

## NoSQL Data Model Types

| Type | Example | ShopEase Use Case |
|------|---------|-------------------|
| Document Store | MongoDB | Orders, products, users |
| Key-Value Store | Redis | Session tokens, shopping cart cache |
| Column Store | Apache Cassandra | Time-series order event logs |
| Graph Database | Neo4j | Product recommendations ("customers also bought") |

For ShopEase, **MongoDB** is the primary NoSQL choice. **Redis** would complement it for caching frequently-read product listings and managing user sessions at scale.

---

## How to Run

1. Create a free cluster at [MongoDB Atlas](https://www.mongodb.com/atlas)
2. Connect via MongoDB Compass or `mongosh`
3. Create a database named `shopease`
4. Run `nosql-model.js` in the mongosh shell:
   ```bash
   mongosh "your-connection-string" --file nosql-model.js
   ```

---

## Status
- [x] MongoDB document model designed
- [x] Collections and sample documents created
- [x] Sample queries implemented
- [x] MongoDB indexes defined
- [x] Comparison with relational model documented
- [x] NoSQL suitability analysis completed
