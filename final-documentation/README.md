# Final Portfolio Documentation
**MIT 8103 — Advanced Database Systems**
**2026/2027 Academic Session | First Semester**

---

## Selected Organisation

**ShopEase** is a B2C e-commerce platform where customers browse and purchase products from multiple vendors. The system handles product listings, inventory management, order processing, payment transactions, and delivery tracking. Users include customers, vendors, admins, and delivery agents. The database stores product catalogues, orders, payments, delivery records, and customer reviews, supporting operations ranging from stock queries to concurrent checkout transactions.

---

## Portfolio Summary

### Portfolio 1: Database Design and Modelling

The ShopEase relational schema was designed in PostgreSQL with 10 tables: `users`, `addresses`, `categories`, `products`, `inventory`, `orders`, `order_items`, `payments`, `deliveries`, and `reviews`. An Entity-Relationship diagram was produced using dbdiagram.io and exported as a PNG.

The schema was normalised progressively from Unnormalised Form (UNF) through First Normal Form (1NF), Second Normal Form (2NF), Third Normal Form (3NF), and Boyce-Codd Normal Form (BCNF). Each stage resolved a specific class of data anomaly: 1NF eliminated repeating groups, 2NF removed partial dependencies, and 3NF removed transitive dependencies. The final schema satisfies BCNF, with all functional dependencies determined solely by primary keys.

Keys and constraints were applied throughout: primary keys on all tables, foreign keys with appropriate `ON DELETE` actions, `CHECK` constraints on status enumerations, ratings, prices, and quantities, and `UNIQUE` constraints on email addresses and the `(user_id, product_id)` pair in reviews.

---

### Portfolio 2: Query Processing and Optimisation

Eight SQL queries were written to cover the core ShopEase business operations: product browsing by category, customer order history, top-selling products, vendor revenue, low-stock alerts, average ratings per category, recent orders, and customers with no orders (using a `LEFT JOIN` anti-pattern).

`EXPLAIN ANALYZE` was run on selected queries before and after adding indexes. Without indexes, PostgreSQL performed Sequential Scans across all rows. After creating indexes on foreign key columns (`vendor_id`, `customer_id`, `order_id`, `product_id`), status columns, and timestamp columns, PostgreSQL switched to Index Scans with significantly lower cost estimates.

Ten indexes were created in total. The analysis confirmed that indexing high-cardinality columns used in `WHERE` clauses and `JOIN` conditions provides the greatest performance gains, while over-indexing write-heavy tables should be avoided due to index maintenance overhead on every `INSERT` and `UPDATE`.

---

### Portfolio 3: Transactions and Concurrency

Six transaction scenarios were implemented to demonstrate atomicity, rollback, savepoints, isolation levels, and deadlock handling.

A successful order placement transaction atomically inserted the order, line items, payment record, and decremented inventory — `COMMIT` made all changes permanent. A payment failure scenario demonstrated `ROLLBACK` restoring all tables to their pre-transaction state. A `SAVEPOINT` example showed how a failed discount application could be rolled back independently without affecting the parent order transaction.

Isolation levels were demonstrated through two concurrent session scenarios. `READ COMMITTED` (PostgreSQL's default) prevented dirty reads. `REPEATABLE READ` prevented non-repeatable reads — essential for the checkout flow where stock availability is checked twice before payment is processed.

A deadlock scenario showed two sessions acquiring locks in opposite order, causing PostgreSQL to detect the circular wait and abort one session. The prevention strategy — acquiring locks in a consistent ascending `product_id` order — was implemented and documented.

---

### Portfolio 4: NoSQL and Advanced Data Models

The ShopEase database was re-modelled in MongoDB using a document-oriented approach. The 10 relational tables were consolidated into 4 collections: `users`, `products`, `orders`, and `reviews`.

Key design decisions included embedding order items, payment details, and delivery status directly inside the order document, enabling a complete order fetch in a single read operation. Product documents embed the stock quantity and category name to avoid joins on the most read-heavy path (product listing). Reviews were kept in a separate collection to prevent unbounded array growth on product documents.

MongoDB indexes were created on high-traffic fields. A comparison of the relational and document models evaluated MongoDB's strengths (schema flexibility, embedded document reads, horizontal scaling) and limitations (no enforced foreign keys, complex cross-collection aggregations, eventual consistency tradeoffs). Redis was identified as a complementary NoSQL tool for session management and product listing caches.

---

### Portfolio 5: Distributed and Cloud Database

The ShopEase schema was deployed to a Supabase cloud PostgreSQL instance. Supabase was selected for its standard PostgreSQL compatibility, free tier, multi-AZ deployment, and built-in connection pooling via PgBouncer.

Distributed database concepts were applied to ShopEase: streaming replication for read scalability and fault tolerance; range-based table partitioning as a sharding simulation for the `orders` table by date; and CAP theorem tradeoffs — consistency prioritised for payment and inventory operations, availability prioritised for product browsing.

Consistency models were mapped to ShopEase operations: strong consistency for payments, eventual consistency for analytics dashboards, and read-your-writes consistency for the order confirmation flow. Connection pooling was explained as essential infrastructure for handling thousands of concurrent users without exhausting PostgreSQL's connection limit.

---

## GitHub Repository

All SQL scripts, MongoDB models, ER diagrams, documentation, and screenshots are maintained at:

**https://github.com/Ikhuemen/advanced-database-portfolio**

The repository is organised into five portfolio folders plus this final documentation folder, with progressive commits made throughout the semester to demonstrate continuous development.

---

## Individual Technical Reflection

Working through this portfolio deepened my understanding of how database design decisions made early in a project propagate through every subsequent layer — from query performance to transaction safety to scalability.

The normalisation exercise (Portfolio 1) was particularly instructive. It is easy to understand normal forms as abstract rules, but tracing a real unnormalised spreadsheet through 1NF, 2NF, 3NF, and BCNF made the purpose of each step concrete. The partial dependency in `order_items` (where price depended only on the product, not the full composite key) was a realistic mistake that normalisation caught.

Query optimisation (Portfolio 2) changed how I think about `EXPLAIN ANALYZE`. Reading an execution plan and understanding why PostgreSQL chose a Sequential Scan over an Index Scan — and how adding an index on a foreign key column changes that decision — is a practical skill that applies immediately to any production database.

The transaction and concurrency work (Portfolio 3) was the most challenging. Understanding isolation levels required thinking about two concurrent sessions simultaneously, which is harder to reason about than a single-session query. The deadlock scenario made the risk of inconsistent lock ordering very clear.

The NoSQL portfolio (Portfolio 4) forced a re-evaluation of assumptions about "correct" data modelling. Embedding order items in the order document feels wrong from a relational perspective but is correct for MongoDB's access patterns — the model should match how the data is read, not just how it is structured.

Finally, the distributed database discussion (Portfolio 5) connected all the previous work to real-world deployment concerns. Designing a schema is only part of the problem; ensuring it performs, scales, and stays consistent under concurrent load in a distributed environment is where advanced database systems knowledge matters most.

---

## References

1. Ramakrishnan, R. & Gehrke, J. (2003). *Database Management Systems* (3rd ed.). McGraw-Hill.
2. Date, C.J. (2004). *An Introduction to Database Systems* (8th ed.). Pearson.
3. PostgreSQL Documentation. (2026). *EXPLAIN, Indexes, Transactions, Isolation Levels*. https://www.postgresql.org/docs/
4. MongoDB Documentation. (2026). *Data Modelling, Aggregation, Indexes*. https://www.mongodb.com/docs/
5. Supabase Documentation. (2026). *Getting Started, Connection Pooling, Replication*. https://supabase.com/docs
6. Brewer, E. (2000). *Towards Robust Distributed Systems* (CAP Theorem). PODC Keynote.

---

## AI Use Declaration

**Tool used:** Claude (Anthropic)

**What it was used for:** Generating SQL schema templates, MongoDB document structure examples, and draft documentation text as a starting framework.

**How the output was reviewed and verified:** All SQL scripts were reviewed line by line and tested against the ShopEase schema for correctness. MongoDB queries were verified in MongoDB Atlas. Explanations and analysis in each README were reviewed against PostgreSQL documentation and course materials to confirm accuracy. The reflection section represents my own observations from working through the portfolio activities.
