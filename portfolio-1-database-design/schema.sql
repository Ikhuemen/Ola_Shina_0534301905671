-- ShopEase E-Commerce Platform — PostgreSQL Schema

CREATE TABLE users (
    id            SERIAL PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role          VARCHAR(20) NOT NULL CHECK (role IN ('customer', 'vendor', 'admin', 'delivery_agent')),
    created_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE addresses (
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    street     VARCHAR(255) NOT NULL,
    city       VARCHAR(100) NOT NULL,
    state      VARCHAR(100) NOT NULL,
    country    VARCHAR(100) NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT FALSE
);

-- parent_id supports subcategories
CREATE TABLE categories (
    id        SERIAL PRIMARY KEY,
    name      VARCHAR(100) NOT NULL UNIQUE,
    parent_id INTEGER REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE products (
    id          SERIAL PRIMARY KEY,
    vendor_id   INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    name        VARCHAR(200) NOT NULL,
    description TEXT,
    price       NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE inventory (
    id         SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL UNIQUE REFERENCES products(id) ON DELETE CASCADE,
    quantity   INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE orders (
    id           SERIAL PRIMARY KEY,
    customer_id  INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    address_id   INTEGER NOT NULL REFERENCES addresses(id) ON DELETE RESTRICT,
    status       VARCHAR(30) NOT NULL DEFAULT 'pending'
                 CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0),
    created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE order_items (
    id         SERIAL PRIMARY KEY,
    order_id   INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity   INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE payments (
    id       SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE REFERENCES orders(id) ON DELETE RESTRICT,
    amount   NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    method   VARCHAR(50) NOT NULL CHECK (method IN ('card', 'bank_transfer', 'wallet')),
    status   VARCHAR(30) NOT NULL DEFAULT 'pending'
             CHECK (status IN ('pending', 'successful', 'failed', 'refunded')),
    paid_at  TIMESTAMP
);

CREATE TABLE deliveries (
    id            SERIAL PRIMARY KEY,
    order_id      INTEGER NOT NULL UNIQUE REFERENCES orders(id) ON DELETE RESTRICT,
    agent_id      INTEGER REFERENCES users(id) ON DELETE SET NULL,
    status        VARCHAR(30) NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'in_transit', 'delivered', 'failed')),
    dispatched_at TIMESTAMP,
    delivered_at  TIMESTAMP
);

CREATE TABLE reviews (
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    rating     INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment    TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, product_id)
);

-- Indexes on foreign keys and frequently filtered columns
CREATE INDEX idx_products_vendor_id     ON products(vendor_id);
CREATE INDEX idx_products_category_id   ON products(category_id);
CREATE INDEX idx_orders_customer_id     ON orders(customer_id);
CREATE INDEX idx_order_items_order_id   ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_reviews_product_id     ON reviews(product_id);
