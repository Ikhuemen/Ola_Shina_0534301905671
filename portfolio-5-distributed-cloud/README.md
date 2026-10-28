# Portfolio 5: Distributed and Cloud Database Exercise

**Case Study:** ShopEase E-Commerce Platform
**Cloud Platform:** Supabase (PostgreSQL-as-a-Service)

---

## Overview

This portfolio explores how the ShopEase relational database can be deployed and managed in a cloud environment, and how distributed database concepts — replication, sharding, availability, and consistency — apply to an e-commerce platform at scale.

---

## Deliverables

| File | Description |
|------|-------------|
| `README.md` | Distributed/cloud database discussion and deployment evidence |
| `screenshots/` | Screenshots of Supabase dashboard, table editor, and SQL editor |

---

## Cloud Deployment: Supabase

### What is Supabase?
Supabase is an open-source Firebase alternative built on top of PostgreSQL. It provides a fully managed PostgreSQL database with a web-based dashboard, REST API, authentication, and real-time subscriptions — all hosted on AWS infrastructure.

### Why Supabase for ShopEase?
- Runs standard PostgreSQL — fully compatible with the schema from Portfolio 1
- Free tier available for development and academic use
- Built-in connection pooling via PgBouncer
- Automatic backups and point-in-time recovery
- Real-time capabilities useful for order status updates and delivery tracking
- Deployed on AWS across multiple availability zones

### Deployment Steps
1. Created a new project at [supabase.com](https://supabase.com)
2. Selected region: **eu-west-1 (Ireland)** for low latency
3. Ran `schema.sql` from Portfolio 1 in the Supabase SQL Editor
4. Verified all 10 tables were created in the Table Editor
5. Inserted sample data and confirmed queries from Portfolio 2 execute correctly

---

## Distributed Database Concepts Applied to ShopEase

### 1. Replication

**What it is:** Replication copies data from a primary database node to one or more replica nodes, providing redundancy and read scalability.

**Supabase implementation:** Supabase runs PostgreSQL with **streaming replication** internally. The primary node handles all writes; read replicas (available on paid plans) can serve read-heavy queries like product listings and order history.

**ShopEase application:**
- Primary node handles: order placement, payment recording, inventory updates
- Read replicas handle: product browsing, search, vendor dashboards, analytics
- This separation prevents heavy read traffic from competing with write transactions

**Replication type used:** Asynchronous streaming replication (primary does not wait for replica acknowledgement before confirming writes — slightly lower consistency for marginally higher write throughput)

---

### 2. Sharding (Horizontal Partitioning)

**What it is:** Sharding splits a large dataset across multiple database servers (shards), each holding a subset of the data. No single server holds the entire dataset.

**ShopEase scenario:** As ShopEase grows to millions of orders, the `orders` and `order_items` tables become the bottleneck. Sharding by `customer_id` distributes customers across shards:

| Shard | Customer ID Range | Data |
|-------|------------------|------|
| Shard 1 | 1 – 500,000 | Orders for customers 1–500k |
| Shard 2 | 500,001 – 1,000,000 | Orders for customers 500k–1M |
| Shard 3 | 1,000,001+ | Orders for customers 1M+ |

**Tradeoff:** Cross-shard queries (e.g. total platform revenue) become expensive — they must query all shards and aggregate results. PostgreSQL's native partitioning (`PARTITION BY RANGE`) was used in this exercise as a simplified sharding simulation.

```sql
-- Simulated partitioning by order creation date
CREATE TABLE orders_2026 PARTITION OF orders
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

CREATE TABLE orders_2027 PARTITION OF orders
    FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');
```

---

### 3. Availability and Fault Tolerance

**CAP Theorem:** A distributed system can guarantee at most two of: **Consistency**, **Availability**, **Partition tolerance**.

**ShopEase design choice:** Prioritise **Consistency + Partition Tolerance (CP)** for payment and inventory operations — it is better to temporarily reject an order than to allow a payment to proceed on stale stock data.

For product browsing and search: prioritise **Availability + Partition Tolerance (AP)** — slightly stale product listings are acceptable; the platform should remain accessible even during partial failures.

**Supabase availability features:**
- Multi-AZ deployment (data replicated across availability zones)
- Automatic failover — if primary fails, a replica is promoted
- 99.9% uptime SLA on Pro plan
- Daily automated backups with point-in-time recovery up to 7 days

---

### 4. Consistency Models

| Model | Description | ShopEase Use |
|-------|-------------|--------------|
| Strong Consistency | All reads see the latest write | Payments, inventory deduction |
| Eventual Consistency | Reads eventually converge to latest write | Product ratings, vendor dashboards |
| Read-Your-Writes | A user always sees their own writes | Order confirmation page |

ShopEase implements **strong consistency** for all financial operations (payments table) via PostgreSQL's ACID transactions, and accepts **eventual consistency** for analytics and reporting dashboards where slight delays are acceptable.

---

### 5. Connection Pooling

At scale, thousands of concurrent users opening direct PostgreSQL connections would exhaust the connection limit. Supabase uses **PgBouncer** as a connection pooler:

- Application connects to PgBouncer (not directly to PostgreSQL)
- PgBouncer maintains a smaller pool of real database connections
- Connections are reused across requests — dramatically reduces overhead
- ShopEase configured with **transaction mode pooling** (connection returned to pool after each transaction)

---

## Architecture Diagram (Text)

```
                        ┌─────────────────────────────┐
                        │      ShopEase Application    │
                        │   (API + Frontend Servers)   │
                        └──────────────┬──────────────┘
                                       │
                        ┌──────────────▼──────────────┐
                        │     PgBouncer (Pool)         │
                        └──────────────┬──────────────┘
                                       │
              ┌────────────────────────▼───────────────────────┐
              │               Supabase PostgreSQL               │
              │  ┌──────────────────┐  ┌─────────────────────┐ │
              │  │  Primary Node    │  │   Read Replica       │ │
              │  │  (Writes)        │──│   (Read Queries)     │ │
              │  └──────────────────┘  └─────────────────────┘ │
              │           │                                      │
              │  ┌────────▼────────┐                            │
              │  │  Standby Node   │ (automatic failover)       │
              │  └─────────────────┘                            │
              └─────────────────────────────────────────────────┘
```

---

## Key Takeaways

1. Cloud databases like Supabase remove infrastructure management overhead, letting the team focus on application logic
2. Replication provides both fault tolerance and read scalability — critical for a growing e-commerce platform
3. Sharding defers data volume problems but introduces query complexity — implement only when needed
4. The CAP theorem forces explicit tradeoffs: ShopEase chooses consistency for payments and availability for browsing
5. Connection pooling is essential at scale — direct PostgreSQL connections do not scale to thousands of concurrent users

---

## Status
- [x] Supabase project created and schema deployed
- [x] Replication concepts documented
- [x] Sharding strategy discussed with SQL partition example
- [x] Availability and CAP theorem applied to ShopEase
- [x] Consistency models documented
- [x] Connection pooling explained
- [x] Architecture diagram included
