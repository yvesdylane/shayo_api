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

create table user_wallet (
    id serial primary key,
    user_id uuid references users(id),
    current_point integer default 0 check (current_point >= 0),
    special_point integer default 0 check (current_point >= 0),
    special_point_expire_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), -- GENERALLY 1 week after obtaining them
    lifetime_point integer default 0 check ( lifetime_point >= 0)
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
    dish_id INTEGER NOT NULL REFERENCES branch_dishes(id) not null,
    user_id UUID NOT NULL REFERENCES users(id) not null,
    message TEXT,
    quality NUMERIC(2,1) CHECK (quality BETWEEN 0 AND 5),
    quantity NUMERIC(2,1) CHECK (quantity BETWEEN 0 AND 5),
    presentation NUMERIC(2,1) CHECK (presentation BETWEEN 0 AND 5),
    overall_rating NUMERIC(3,2) GENERATED ALWAYS AS (
        (COALESCE(quality, 0) + COALESCE(quantity, 0) + COALESCE(presentation, 0)) /
        NULLIF((quality IS NOT NULL)::INT + (quantity IS NOT NULL)::INT + (presentation IS NOT NULL)::INT, 0 ) ) STORED,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, dish_id)
);

Create table drink_review (
    id bigserial primary key,
    drink_id integer references branch_drinks(id) not null,
    user_id uuid references users(id) not null,
    message TEXT,
    quality NUMERIC(2,1) CHECK (quality BETWEEN 0 AND 5),
    quantity NUMERIC(2,1) CHECK (quantity BETWEEN 0 AND 5),
    presentation NUMERIC(2,1) CHECK (presentation BETWEEN 0 AND 5),
    overall_rating NUMERIC(3,2) GENERATED ALWAYS AS (
        (COALESCE(quality, 0) + COALESCE(quantity, 0) + COALESCE(presentation, 0)) /
        NULLIF((quality IS NOT NULL)::INT + (quantity IS NOT NULL)::INT + (presentation IS NOT NULL)::INT, 0 ) ) STORED,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, dish_id)
);

Create table branch_review (
    id bigserial primary key,
    branch_id integer references restaurant_branches(id) not null,
    user_id uuid references users(id) not null,
    message TEXT,
    quality NUMERIC(2,1) CHECK (quality BETWEEN 0 AND 5),
    quantity NUMERIC(2,1) CHECK (quantity BETWEEN 0 AND 5),
    presentation NUMERIC(2,1) CHECK (presentation BETWEEN 0 AND 5),
    overall_rating NUMERIC(3,2) GENERATED ALWAYS AS (
      (COALESCE(quality, 0) + COALESCE(quantity, 0) + COALESCE(presentation, 0)) /
      NULLIF((quality IS NOT NULL)::INT + (quantity IS NOT NULL)::INT + (presentation IS NOT NULL)::INT, 0 ) ) STORED,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, dish_id)
);

create table user_notifications(
    id serial primary key,
    user_id uuid references users(id),
    content text not null,
    is_read boolean default false,
    created_at timestampz not null default now()
);

create table branch_notifications(
    id serial primary key,
    branch_id integer references restaurant_branches(id),
    content text not null,
    is_read boolean default false,
    created_at timestampz not null default now()
)

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
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    branch_id INTEGER REFERENCES restaurant_branches(id) ON DELETE SET NULL,
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
    status order_status DEFAULT 'pending',
    is_delivery BOOLEAN DEFAULT FALSE,
    delivery_address TEXT,
    special_instructions TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- payment for an order done through points and can be subjected to reductions or special event
CREATE table payment(
    order_id bigint references orders(id),
    points
);

CREATE TABLE order_drinks (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    drink_id integer not null references branch_drinks(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0)
);

CREATE TABLE order_dish (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    dish_id integer not null references branch_dishes(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0)
);

CREATE TYPE transaction_type AS ENUM (
    'top_up',
    'withdrawer'
);

CREATE TABLE transactions (
    id BIGSERIAL PRIMARY KEY,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    reason TEXT,
    type transaction_type,
    trx_id VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP,
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