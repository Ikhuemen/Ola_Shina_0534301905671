// ============================================================
// ShopEase E-Commerce Platform
// Portfolio 4: NoSQL and Advanced Data Models
// MongoDB Document Model
// MIT 8103 Advanced Database Systems
// ============================================================
// Run these examples in MongoDB Shell (mongosh) or MongoDB Atlas
// Data Explorer after connecting to your cluster
// ============================================================

// ------------------------------------------------------------
// COLLECTION 1: users
// Embeds default address directly in the user document
// for fast retrieval without a join
// ------------------------------------------------------------
db.users.insertMany([
  {
    _id: "usr_001",
    full_name: "John Doe",
    email: "john@example.com",
    password_hash: "$2b$10$examplehash1",
    role: "customer",
    default_address: {
      street: "12 Oak Street",
      city: "Lagos",
      state: "Lagos",
      country: "Nigeria"
    },
    created_at: new Date("2026-01-15")
  },
  {
    _id: "usr_002",
    full_name: "TechVend Ltd",
    email: "vendor@techvend.com",
    password_hash: "$2b$10$examplehash2",
    role: "vendor",
    created_at: new Date("2026-02-01")
  },
  {
    _id: "usr_003",
    full_name: "Jane Smith",
    email: "jane@example.com",
    password_hash: "$2b$10$examplehash3",
    role: "customer",
    default_address: {
      street: "5 Park Avenue",
      city: "Abuja",
      state: "FCT",
      country: "Nigeria"
    },
    created_at: new Date("2026-03-10")
  }
]);


// ------------------------------------------------------------
// COLLECTION 2: products
// Embeds inventory quantity and category name directly
// to avoid lookups at read time
// ------------------------------------------------------------
db.products.insertMany([
  {
    _id: "prd_001",
    vendor_id: "usr_002",
    name: "HP Laptop 15",
    description: "Intel Core i5, 8GB RAM, 512GB SSD",
    price: 850.00,
    category: "Electronics",
    stock: 45,
    tags: ["laptop", "computer", "hp"],
    created_at: new Date("2026-02-10")
  },
  {
    _id: "prd_002",
    vendor_id: "usr_002",
    name: "Wireless Mouse",
    description: "Ergonomic 2.4GHz wireless mouse",
    price: 25.00,
    category: "Electronics",
    stock: 120,
    tags: ["mouse", "wireless", "accessories"],
    created_at: new Date("2026-02-12")
  },
  {
    _id: "prd_003",
    vendor_id: "usr_002",
    name: "Samsung Galaxy A54",
    description: "6.4 inch AMOLED, 128GB, 5G",
    price: 600.00,
    category: "Phones",
    stock: 30,
    tags: ["phone", "samsung", "android", "5g"],
    created_at: new Date("2026-03-01")
  }
]);


// ------------------------------------------------------------
// COLLECTION 3: orders
// Embeds order_items array directly in the order document
// A single document fetch retrieves the complete order
// ------------------------------------------------------------
db.orders.insertMany([
  {
    _id: "ord_001",
    customer_id: "usr_001",
    shipping_address: {
      street: "12 Oak Street",
      city: "Lagos",
      state: "Lagos",
      country: "Nigeria"
    },
    status: "delivered",
    items: [
      { product_id: "prd_001", name: "HP Laptop 15", quantity: 1, unit_price: 850.00 },
      { product_id: "prd_002", name: "Wireless Mouse", quantity: 2, unit_price: 25.00 }
    ],
    total_amount: 900.00,
    payment: {
      method: "card",
      status: "successful",
      paid_at: new Date("2026-04-01T10:30:00Z")
    },
    delivery: {
      agent_id: "usr_004",
      status: "delivered",
      dispatched_at: new Date("2026-04-02T08:00:00Z"),
      delivered_at: new Date("2026-04-03T14:20:00Z")
    },
    created_at: new Date("2026-04-01T09:00:00Z")
  },
  {
    _id: "ord_002",
    customer_id: "usr_003",
    shipping_address: {
      street: "5 Park Avenue",
      city: "Abuja",
      state: "FCT",
      country: "Nigeria"
    },
    status: "shipped",
    items: [
      { product_id: "prd_003", name: "Samsung Galaxy A54", quantity: 1, unit_price: 600.00 }
    ],
    total_amount: 600.00,
    payment: {
      method: "wallet",
      status: "successful",
      paid_at: new Date("2026-04-05T11:00:00Z")
    },
    delivery: {
      status: "in_transit",
      dispatched_at: new Date("2026-04-06T09:00:00Z"),
      delivered_at: null
    },
    created_at: new Date("2026-04-05T10:45:00Z")
  }
]);


// ------------------------------------------------------------
// COLLECTION 4: reviews
// Stored as a separate collection for independent querying
// and to avoid unbounded array growth on product documents
// ------------------------------------------------------------
db.reviews.insertMany([
  {
    _id: "rev_001",
    user_id: "usr_001",
    product_id: "prd_001",
    rating: 5,
    comment: "Excellent laptop, fast and reliable.",
    created_at: new Date("2026-04-10")
  },
  {
    _id: "rev_002",
    user_id: "usr_003",
    product_id: "prd_003",
    rating: 4,
    comment: "Great phone, battery life could be better.",
    created_at: new Date("2026-04-12")
  }
]);


// ============================================================
// SAMPLE QUERIES
// ============================================================

// Find all Electronics products with stock > 0, sorted by price
db.products.find(
  { category: "Electronics", stock: { $gt: 0 } },
  { name: 1, price: 1, stock: 1 }
).sort({ price: -1 });

// Find all delivered orders for a specific customer
db.orders.find(
  { customer_id: "usr_001", status: "delivered" }
);

// Get average rating for a product
db.reviews.aggregate([
  { $match: { product_id: "prd_001" } },
  { $group: { _id: "$product_id", avg_rating: { $avg: "$rating" }, total: { $sum: 1 } } }
]);

// Full-text search on product tags
db.products.createIndex({ tags: 1 });
db.products.find({ tags: "wireless" });

// ============================================================
// INDEXES FOR MONGODB COLLECTIONS
// ============================================================
db.products.createIndex({ category: 1, price: -1 });
db.products.createIndex({ vendor_id: 1 });
db.orders.createIndex({ customer_id: 1, created_at: -1 });
db.orders.createIndex({ status: 1 });
db.reviews.createIndex({ product_id: 1 });
db.users.createIndex({ email: 1 }, { unique: true });
