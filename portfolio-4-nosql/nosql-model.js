// ShopEase — MongoDB Document Model
// Run in mongosh or MongoDB Atlas Data Explorer

// users — default address embedded for single-read retrieval
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


// products — stock and category embedded to avoid lookups on reads
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


// orders — items, payment, and delivery embedded in one document
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


// reviews — separate collection to avoid unbounded array growth on products
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


// Sample queries

db.products.find(
  { category: "Electronics", stock: { $gt: 0 } },
  { name: 1, price: 1, stock: 1 }
).sort({ price: -1 });

db.orders.find({ customer_id: "usr_001", status: "delivered" });

db.reviews.aggregate([
  { $match: { product_id: "prd_001" } },
  { $group: { _id: "$product_id", avg_rating: { $avg: "$rating" }, total: { $sum: 1 } } }
]);

db.products.find({ tags: "wireless" });


// Indexes
db.users.createIndex({ email: 1 }, { unique: true });
db.products.createIndex({ category: 1, price: -1 });
db.products.createIndex({ vendor_id: 1 });
db.products.createIndex({ tags: 1 });
db.orders.createIndex({ customer_id: 1, created_at: -1 });
db.orders.createIndex({ status: 1 });
db.reviews.createIndex({ product_id: 1 });
