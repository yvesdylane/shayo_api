CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(50),
    sur_name VARCHAR(50),
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) UNIQUE,
    user_name VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    bio TEXT,
    dob DATE,
    region VARCHAR(50),
    image VARCHAR(255),
    is_verified BOOLEAN DEFAULT FALSE,
    code VARCHAR(8),
    code_expire_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    verified_at TIMESTAMPTZ,
    last_login TIMESTAMPTZ
);

CREATE TABLE user_wallet (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE REFERENCES users(id),
    current_point INTEGER DEFAULT 0 CHECK (current_point >= 0),
    lifetime_point INTEGER DEFAULT 0 CHECK (lifetime_point >= 0)
);

-- Individual special point grants with per-grant expiry tracking
CREATE TABLE special_point_grants (
    id SERIAL PRIMARY KEY,
    wallet_id INTEGER NOT NULL REFERENCES user_wallet(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL CHECK (amount > 0),
    remaining INTEGER NOT NULL CHECK (remaining >= 0),
    expires_at TIMESTAMPTZ NOT NULL,
    source VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Platform admins
CREATE TABLE admins (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    rank VARCHAR(2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Restaurants
CREATE TABLE restaurants (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    logo VARCHAR(255),
    image VARCHAR(255),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    rating FLOAT DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Restaurant branches
CREATE TABLE restaurant_branches (
    id SERIAL PRIMARY KEY,
    restaurant_id INTEGER NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    image VARCHAR(255),
    name VARCHAR(100) NOT NULL,
    location TEXT,
    email VARCHAR(100),
    phone VARCHAR(20),
    rating FLOAT DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE restaurant_users(
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    restaurant_id INTEGER NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    rank VARCHAR(2) NOT NULL,
    restaurant_branch_id INTEGER REFERENCES restaurant_branches(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, restaurant_id, restaurant_branch_id)
);

CREATE TYPE food_type AS ENUM (
    'appetizer',
    'main_course',
    'dessert',
    'chewable'
);

-- General dishes catalog
CREATE TABLE dishes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type food_type,
    origin VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TYPE drink_type AS ENUM (
    'juice',
    'fruit_juice',
    'homemade_alcohol',
    'whisky',
    'wine',
    'beer',
    'soft_drink',
    'water'
);

-- General drinks catalog
CREATE TABLE drinks (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type drink_type,
    description TEXT,
    origin VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Restaurant-specific dishes (with pricing)
CREATE TABLE restaurant_dishes (
    id SERIAL PRIMARY KEY,
    dish_id INTEGER NOT NULL REFERENCES dishes(id) ON DELETE CASCADE,
    restaurant_id INTEGER NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    is_available BOOLEAN DEFAULT TRUE,
    rating FLOAT DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(dish_id, restaurant_id)
);

-- Restaurant-specific drinks (with pricing)
CREATE TABLE restaurant_drinks (
    id SERIAL PRIMARY KEY,
    drink_id INTEGER NOT NULL REFERENCES drinks(id) ON DELETE CASCADE,
    restaurant_id INTEGER NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    is_available BOOLEAN DEFAULT TRUE,
    rating FLOAT DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(drink_id, restaurant_id)
);

-- Branch-specific dishes (override pricing/availability)
CREATE TABLE branch_dishes (
    id SERIAL PRIMARY KEY,
    branch_id INTEGER NOT NULL REFERENCES restaurant_branches(id) ON DELETE CASCADE,
    restaurant_dish_id INTEGER NOT NULL REFERENCES restaurant_dishes(id) ON DELETE CASCADE,
    price DECIMAL(10, 2) CHECK (price >= 0),
    is_available BOOLEAN DEFAULT TRUE,
    rating FLOAT DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(branch_id, restaurant_dish_id)
);

-- Branch-specific drinks (override pricing/availability)
CREATE TABLE branch_drinks (
    id SERIAL PRIMARY KEY,
    branch_id INTEGER NOT NULL REFERENCES restaurant_branches(id) ON DELETE CASCADE,
    restaurant_drink_id INTEGER NOT NULL REFERENCES restaurant_drinks(id) ON DELETE CASCADE,
    price DECIMAL(10, 2) CHECK (price >= 0),
    is_available BOOLEAN DEFAULT TRUE,
    rating FLOAT DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(branch_id, restaurant_drink_id)
);

CREATE TABLE dish_review (
    id BIGSERIAL PRIMARY KEY,
    dish_id INTEGER NOT NULL REFERENCES branch_dishes(id),
    user_id UUID NOT NULL REFERENCES users(id),
    message TEXT,
    quality NUMERIC(2,1) CHECK (quality BETWEEN 0 AND 5),
    quantity NUMERIC(2,1) CHECK (quantity BETWEEN 0 AND 5),
    presentation NUMERIC(2,1) CHECK (presentation BETWEEN 0 AND 5),
    overall_rating NUMERIC(3,2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, dish_id)
);

CREATE TABLE drink_review (
    id BIGSERIAL PRIMARY KEY,
    drink_id INTEGER NOT NULL REFERENCES branch_drinks(id),
    user_id UUID NOT NULL REFERENCES users(id),
    message TEXT,
    quality NUMERIC(2,1) CHECK (quality BETWEEN 0 AND 5),
    quantity NUMERIC(2,1) CHECK (quantity BETWEEN 0 AND 5),
    presentation NUMERIC(2,1) CHECK (presentation BETWEEN 0 AND 5),
    overall_rating NUMERIC(3,2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, drink_id)
);

CREATE TABLE branch_review (
    id BIGSERIAL PRIMARY KEY,
    branch_id INTEGER NOT NULL REFERENCES restaurant_branches(id),
    user_id UUID NOT NULL REFERENCES users(id),
    message TEXT,
    quality NUMERIC(2,1) CHECK (quality BETWEEN 0 AND 5),
    quantity NUMERIC(2,1) CHECK (quantity BETWEEN 0 AND 5),
    presentation NUMERIC(2,1) CHECK (presentation BETWEEN 0 AND 5),
    overall_rating NUMERIC(3,2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, branch_id)
);

CREATE TABLE user_notifications(
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE branch_notifications(
    id SERIAL PRIMARY KEY,
    branch_id INTEGER REFERENCES restaurant_branches(id),
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TYPE order_status AS ENUM (
    'pending',
    'confirmed',
    'preparing',
    'ready',
    'out_for_delivery',
    'delivered',
    'cancelled',
    'completed'
);

CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    branch_id INTEGER REFERENCES restaurant_branches(id) ON DELETE SET NULL,
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
    status order_status DEFAULT 'pending',
    is_delivery BOOLEAN DEFAULT FALSE,
    delivery_address TEXT,
    special_instructions TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- payment for an order done through points; user_id is the payer (may differ from order owner)
CREATE TABLE payment(
    user_id UUID NOT NULL REFERENCES users(id),
    order_id BIGINT REFERENCES orders(id) PRIMARY KEY,
    points INTEGER,
    deduction INTEGER DEFAULT NULL,
    reason TEXT
);

CREATE TABLE order_drinks (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    drink_id INTEGER NOT NULL REFERENCES branch_drinks(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0)
);

CREATE TABLE order_dish (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    dish_id INTEGER NOT NULL REFERENCES branch_dishes(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0)
);

CREATE TYPE transaction_type AS ENUM (
    'top_up',
    'withdrawer'
);

CREATE TYPE transaction_provider AS ENUM (
    'mtn_momo',
    'orange_money'
);

CREATE TABLE transactions (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    branch_id INTEGER REFERENCES restaurant_branches(id),
    provider transaction_provider NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    reason TEXT,
    type transaction_type,
    trx_id VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE branch_wallets (
    id SERIAL PRIMARY KEY,
    branch_id INTEGER UNIQUE NOT NULL REFERENCES restaurant_branches(id) ON DELETE CASCADE,
    restaurant_id INTEGER NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    current_balance DECIMAL(12, 2) DEFAULT 0 CHECK (current_balance >= 0),
    total_earned DECIMAL(12, 2) DEFAULT 0 CHECK (total_earned >= 0),
    total_spent DECIMAL(12, 2) DEFAULT 0 CHECK (total_spent >= 0),
    pending_balance DECIMAL(12, 2) DEFAULT 0 CHECK (pending_balance >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TYPE promotion_type AS ENUM (
    'top_up_bonus',
    'order_deduction',
    'special_point_grant'
);

CREATE TABLE promotions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type promotion_type NOT NULL,
    config JSONB NOT NULL DEFAULT '{}',
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE system_settings (
    id SERIAL PRIMARY KEY,
    number VARCHAR(16) DEFAULT '+237652650173',
    conversion_rate INTEGER DEFAULT 1
);

-- Indexes for performance
CREATE INDEX idx_user_wallet_user_id ON user_wallet(user_id);
CREATE INDEX idx_special_point_grants_wallet_id ON special_point_grants(wallet_id);
CREATE INDEX idx_special_point_grants_expires_at ON special_point_grants(expires_at);
CREATE INDEX idx_admins_user_id ON admins(user_id);
CREATE INDEX idx_restaurant_branches_restaurant_id ON restaurant_branches(restaurant_id);
CREATE INDEX idx_restaurant_users_user_id ON restaurant_users(user_id);
CREATE INDEX idx_restaurant_users_restaurant_id ON restaurant_users(restaurant_id);
CREATE INDEX idx_restaurant_dishes_restaurant_id ON restaurant_dishes(restaurant_id);
CREATE INDEX idx_restaurant_drinks_restaurant_id ON restaurant_drinks(restaurant_id);
CREATE INDEX idx_branch_dishes_branch_id ON branch_dishes(branch_id);
CREATE INDEX idx_branch_drinks_branch_id ON branch_drinks(branch_id);
CREATE INDEX idx_dish_review_dish_id ON dish_review(dish_id);
CREATE INDEX idx_dish_review_user_id ON dish_review(user_id);
CREATE INDEX idx_drink_review_drink_id ON drink_review(drink_id);
CREATE INDEX idx_drink_review_user_id ON drink_review(user_id);
CREATE INDEX idx_branch_review_branch_id ON branch_review(branch_id);
CREATE INDEX idx_branch_review_user_id ON branch_review(user_id);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_branch_id ON orders(branch_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_order_dish_order_id ON order_dish(order_id);
CREATE INDEX idx_order_drinks_order_id ON order_drinks(order_id);
CREATE INDEX idx_payment_user_id ON payment(user_id);
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_branch_id ON transactions(branch_id);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_user_notifications_user_id ON user_notifications(user_id);
CREATE INDEX idx_branch_notifications_branch_id ON branch_notifications(branch_id);
CREATE INDEX idx_branch_wallets_branch_id ON branch_wallets(branch_id);
CREATE INDEX idx_promotions_type ON promotions(type);
CREATE INDEX idx_promotions_dates ON promotions(start_date, end_date);
