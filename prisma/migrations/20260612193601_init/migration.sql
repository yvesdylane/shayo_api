-- CreateEnum
CREATE TYPE "food_type" AS ENUM ('appetizer', 'main_course', 'dessert', 'chewable');

-- CreateEnum
CREATE TYPE "drink_type" AS ENUM ('juice', 'fruit_juice', 'homemade_alcohol', 'whisky', 'wine', 'beer', 'soft_drink', 'water');

-- CreateEnum
CREATE TYPE "order_status" AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'out_for_delivery', 'delivered', 'cancelled', 'completed');

-- CreateEnum
CREATE TYPE "transaction_type" AS ENUM ('top_up', 'withdrawer');

-- CreateEnum
CREATE TYPE "transaction_provider" AS ENUM ('mtn_momo', 'orange_money');

-- CreateEnum
CREATE TYPE "promotion_type" AS ENUM ('top_up_bonus', 'order_deduction', 'special_point_grant');

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "first_name" VARCHAR(50),
    "sur_name" VARCHAR(50),
    "email" VARCHAR(100) NOT NULL,
    "phone" VARCHAR(20),
    "user_name" VARCHAR(50) NOT NULL,
    "password" VARCHAR(255) NOT NULL,
    "bio" TEXT,
    "dob" DATE,
    "region" VARCHAR(50),
    "image" VARCHAR(255),
    "is_verified" BOOLEAN NOT NULL DEFAULT false,
    "code" VARCHAR(8),
    "code_expire_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,
    "verified_at" TIMESTAMPTZ,
    "last_login" TIMESTAMPTZ,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_wallet" (
    "id" SERIAL NOT NULL,
    "user_id" UUID NOT NULL,
    "current_point" INTEGER NOT NULL DEFAULT 0,
    "lifetime_point" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "user_wallet_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "special_point_grants" (
    "id" SERIAL NOT NULL,
    "wallet_id" INTEGER NOT NULL,
    "amount" INTEGER NOT NULL,
    "remaining" INTEGER NOT NULL,
    "expires_at" TIMESTAMPTZ NOT NULL,
    "source" VARCHAR(255),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "special_point_grants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "admins" (
    "id" SERIAL NOT NULL,
    "user_id" UUID NOT NULL,
    "rank" VARCHAR(2) NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "admins_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "restaurants" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "logo" VARCHAR(255),
    "image" VARCHAR(255),
    "email" VARCHAR(100),
    "phone" VARCHAR(20),
    "rating" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "is_verified" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "restaurants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "restaurant_branches" (
    "id" SERIAL NOT NULL,
    "restaurant_id" INTEGER NOT NULL,
    "image" VARCHAR(255),
    "name" VARCHAR(100) NOT NULL,
    "location" TEXT,
    "email" VARCHAR(100),
    "phone" VARCHAR(20),
    "rating" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "restaurant_branches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "restaurant_users" (
    "id" SERIAL NOT NULL,
    "user_id" UUID NOT NULL,
    "restaurant_id" INTEGER NOT NULL,
    "rank" VARCHAR(2) NOT NULL,
    "restaurant_branch_id" INTEGER,

    CONSTRAINT "restaurant_users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "dishes" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "type" "food_type",
    "origin" VARCHAR(50),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "dishes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "drinks" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "type" "drink_type",
    "description" TEXT,
    "origin" VARCHAR(50),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "drinks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "restaurant_dishes" (
    "id" SERIAL NOT NULL,
    "dish_id" INTEGER NOT NULL,
    "restaurant_id" INTEGER NOT NULL,
    "price" DECIMAL(10,2) NOT NULL,
    "is_available" BOOLEAN NOT NULL DEFAULT true,
    "rating" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "restaurant_dishes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "restaurant_drinks" (
    "id" SERIAL NOT NULL,
    "drink_id" INTEGER NOT NULL,
    "restaurant_id" INTEGER NOT NULL,
    "price" DECIMAL(10,2) NOT NULL,
    "is_available" BOOLEAN NOT NULL DEFAULT true,
    "rating" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "restaurant_drinks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branch_dishes" (
    "id" SERIAL NOT NULL,
    "branch_id" INTEGER NOT NULL,
    "restaurant_dish_id" INTEGER NOT NULL,
    "price" DECIMAL(10,2),
    "is_available" BOOLEAN NOT NULL DEFAULT true,
    "rating" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "branch_dishes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branch_drinks" (
    "id" SERIAL NOT NULL,
    "branch_id" INTEGER NOT NULL,
    "restaurant_drink_id" INTEGER NOT NULL,
    "price" DECIMAL(10,2),
    "is_available" BOOLEAN NOT NULL DEFAULT true,
    "rating" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "branch_drinks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "dish_review" (
    "id" BIGSERIAL NOT NULL,
    "dish_id" INTEGER NOT NULL,
    "user_id" UUID NOT NULL,
    "message" TEXT,
    "quality" DECIMAL(2,1),
    "quantity" DECIMAL(2,1),
    "presentation" DECIMAL(2,1),
    "overall_rating" DECIMAL(3,2),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "dish_review_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "drink_review" (
    "id" BIGSERIAL NOT NULL,
    "drink_id" INTEGER NOT NULL,
    "user_id" UUID NOT NULL,
    "message" TEXT,
    "quality" DECIMAL(2,1),
    "quantity" DECIMAL(2,1),
    "presentation" DECIMAL(2,1),
    "overall_rating" DECIMAL(3,2),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "drink_review_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branch_review" (
    "id" BIGSERIAL NOT NULL,
    "branch_id" INTEGER NOT NULL,
    "user_id" UUID NOT NULL,
    "message" TEXT,
    "quality" DECIMAL(2,1),
    "quantity" DECIMAL(2,1),
    "presentation" DECIMAL(2,1),
    "overall_rating" DECIMAL(3,2),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "branch_review_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_notifications" (
    "id" SERIAL NOT NULL,
    "user_id" UUID NOT NULL,
    "content" TEXT NOT NULL,
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branch_notifications" (
    "id" SERIAL NOT NULL,
    "branch_id" INTEGER NOT NULL,
    "content" TEXT NOT NULL,
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "branch_notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "orders" (
    "id" BIGSERIAL NOT NULL,
    "user_id" UUID,
    "branch_id" INTEGER,
    "total_price" DECIMAL(10,2) NOT NULL,
    "status" "order_status" NOT NULL DEFAULT 'pending',
    "is_delivery" BOOLEAN NOT NULL DEFAULT false,
    "delivery_address" TEXT,
    "special_instructions" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment" (
    "user_id" UUID NOT NULL,
    "order_id" BIGINT NOT NULL,
    "points" INTEGER,
    "deduction" INTEGER,
    "reason" TEXT,

    CONSTRAINT "payment_pkey" PRIMARY KEY ("order_id")
);

-- CreateTable
CREATE TABLE "order_dish" (
    "id" BIGSERIAL NOT NULL,
    "order_id" BIGINT NOT NULL,
    "dish_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unit_price" DECIMAL(10,2) NOT NULL,
    "total_price" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "order_dish_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_drinks" (
    "id" BIGSERIAL NOT NULL,
    "order_id" BIGINT NOT NULL,
    "drink_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unit_price" DECIMAL(10,2) NOT NULL,
    "total_price" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "order_drinks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "transactions" (
    "id" BIGSERIAL NOT NULL,
    "user_id" UUID NOT NULL,
    "branch_id" INTEGER,
    "provider" "transaction_provider" NOT NULL,
    "amount" DECIMAL(10,2) NOT NULL,
    "reason" TEXT,
    "type" "transaction_type",
    "trx_id" VARCHAR(255) NOT NULL,
    "phone" VARCHAR(20),
    "is_verified" BOOLEAN NOT NULL DEFAULT false,
    "verified_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "transactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branch_wallets" (
    "id" SERIAL NOT NULL,
    "branch_id" INTEGER NOT NULL,
    "restaurant_id" INTEGER NOT NULL,
    "current_balance" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "total_earned" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "total_spent" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "pending_balance" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "branch_wallets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "promotions" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "type" "promotion_type" NOT NULL,
    "config" JSONB NOT NULL DEFAULT '{}',
    "start_date" TIMESTAMPTZ NOT NULL,
    "end_date" TIMESTAMPTZ,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "promotions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "system_settings" (
    "id" SERIAL NOT NULL,
    "number" VARCHAR(16) NOT NULL DEFAULT '+237652650173',
    "conversion_rate" INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT "system_settings_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "users_user_name_key" ON "users"("user_name");

-- CreateIndex
CREATE UNIQUE INDEX "user_wallet_user_id_key" ON "user_wallet"("user_id");

-- CreateIndex
CREATE INDEX "user_wallet_user_id_idx" ON "user_wallet"("user_id");

-- CreateIndex
CREATE INDEX "special_point_grants_wallet_id_idx" ON "special_point_grants"("wallet_id");

-- CreateIndex
CREATE INDEX "special_point_grants_expires_at_idx" ON "special_point_grants"("expires_at");

-- CreateIndex
CREATE UNIQUE INDEX "admins_user_id_key" ON "admins"("user_id");

-- CreateIndex
CREATE INDEX "admins_user_id_idx" ON "admins"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "restaurants_email_key" ON "restaurants"("email");

-- CreateIndex
CREATE INDEX "restaurant_branches_restaurant_id_idx" ON "restaurant_branches"("restaurant_id");

-- CreateIndex
CREATE INDEX "restaurant_users_user_id_idx" ON "restaurant_users"("user_id");

-- CreateIndex
CREATE INDEX "restaurant_users_restaurant_id_idx" ON "restaurant_users"("restaurant_id");

-- CreateIndex
CREATE UNIQUE INDEX "restaurant_users_user_id_restaurant_id_restaurant_branch_id_key" ON "restaurant_users"("user_id", "restaurant_id", "restaurant_branch_id");

-- CreateIndex
CREATE INDEX "restaurant_dishes_restaurant_id_idx" ON "restaurant_dishes"("restaurant_id");

-- CreateIndex
CREATE UNIQUE INDEX "restaurant_dishes_dish_id_restaurant_id_key" ON "restaurant_dishes"("dish_id", "restaurant_id");

-- CreateIndex
CREATE INDEX "restaurant_drinks_restaurant_id_idx" ON "restaurant_drinks"("restaurant_id");

-- CreateIndex
CREATE UNIQUE INDEX "restaurant_drinks_drink_id_restaurant_id_key" ON "restaurant_drinks"("drink_id", "restaurant_id");

-- CreateIndex
CREATE INDEX "branch_dishes_branch_id_idx" ON "branch_dishes"("branch_id");

-- CreateIndex
CREATE UNIQUE INDEX "branch_dishes_branch_id_restaurant_dish_id_key" ON "branch_dishes"("branch_id", "restaurant_dish_id");

-- CreateIndex
CREATE INDEX "branch_drinks_branch_id_idx" ON "branch_drinks"("branch_id");

-- CreateIndex
CREATE UNIQUE INDEX "branch_drinks_branch_id_restaurant_drink_id_key" ON "branch_drinks"("branch_id", "restaurant_drink_id");

-- CreateIndex
CREATE INDEX "dish_review_dish_id_idx" ON "dish_review"("dish_id");

-- CreateIndex
CREATE INDEX "dish_review_user_id_idx" ON "dish_review"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "dish_review_user_id_dish_id_key" ON "dish_review"("user_id", "dish_id");

-- CreateIndex
CREATE INDEX "drink_review_drink_id_idx" ON "drink_review"("drink_id");

-- CreateIndex
CREATE INDEX "drink_review_user_id_idx" ON "drink_review"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "drink_review_user_id_drink_id_key" ON "drink_review"("user_id", "drink_id");

-- CreateIndex
CREATE INDEX "branch_review_branch_id_idx" ON "branch_review"("branch_id");

-- CreateIndex
CREATE INDEX "branch_review_user_id_idx" ON "branch_review"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "branch_review_user_id_branch_id_key" ON "branch_review"("user_id", "branch_id");

-- CreateIndex
CREATE INDEX "user_notifications_user_id_idx" ON "user_notifications"("user_id");

-- CreateIndex
CREATE INDEX "branch_notifications_branch_id_idx" ON "branch_notifications"("branch_id");

-- CreateIndex
CREATE INDEX "orders_user_id_idx" ON "orders"("user_id");

-- CreateIndex
CREATE INDEX "orders_branch_id_idx" ON "orders"("branch_id");

-- CreateIndex
CREATE INDEX "orders_status_idx" ON "orders"("status");

-- CreateIndex
CREATE INDEX "orders_created_at_idx" ON "orders"("created_at");

-- CreateIndex
CREATE INDEX "payment_user_id_idx" ON "payment"("user_id");

-- CreateIndex
CREATE INDEX "order_dish_order_id_idx" ON "order_dish"("order_id");

-- CreateIndex
CREATE INDEX "order_drinks_order_id_idx" ON "order_drinks"("order_id");

-- CreateIndex
CREATE UNIQUE INDEX "transactions_trx_id_key" ON "transactions"("trx_id");

-- CreateIndex
CREATE INDEX "transactions_user_id_idx" ON "transactions"("user_id");

-- CreateIndex
CREATE INDEX "transactions_branch_id_idx" ON "transactions"("branch_id");

-- CreateIndex
CREATE INDEX "transactions_created_at_idx" ON "transactions"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "branch_wallets_branch_id_key" ON "branch_wallets"("branch_id");

-- CreateIndex
CREATE INDEX "branch_wallets_branch_id_idx" ON "branch_wallets"("branch_id");

-- CreateIndex
CREATE INDEX "promotions_type_idx" ON "promotions"("type");

-- CreateIndex
CREATE INDEX "promotions_start_date_end_date_idx" ON "promotions"("start_date", "end_date");

-- AddForeignKey
ALTER TABLE "user_wallet" ADD CONSTRAINT "user_wallet_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "special_point_grants" ADD CONSTRAINT "special_point_grants_wallet_id_fkey" FOREIGN KEY ("wallet_id") REFERENCES "user_wallet"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "admins" ADD CONSTRAINT "admins_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "restaurant_branches" ADD CONSTRAINT "restaurant_branches_restaurant_id_fkey" FOREIGN KEY ("restaurant_id") REFERENCES "restaurants"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "restaurant_users" ADD CONSTRAINT "restaurant_users_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "restaurant_users" ADD CONSTRAINT "restaurant_users_restaurant_id_fkey" FOREIGN KEY ("restaurant_id") REFERENCES "restaurants"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "restaurant_users" ADD CONSTRAINT "restaurant_users_restaurant_branch_id_fkey" FOREIGN KEY ("restaurant_branch_id") REFERENCES "restaurant_branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "restaurant_dishes" ADD CONSTRAINT "restaurant_dishes_dish_id_fkey" FOREIGN KEY ("dish_id") REFERENCES "dishes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "restaurant_dishes" ADD CONSTRAINT "restaurant_dishes_restaurant_id_fkey" FOREIGN KEY ("restaurant_id") REFERENCES "restaurants"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "restaurant_drinks" ADD CONSTRAINT "restaurant_drinks_drink_id_fkey" FOREIGN KEY ("drink_id") REFERENCES "drinks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "restaurant_drinks" ADD CONSTRAINT "restaurant_drinks_restaurant_id_fkey" FOREIGN KEY ("restaurant_id") REFERENCES "restaurants"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branch_dishes" ADD CONSTRAINT "branch_dishes_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "restaurant_branches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branch_dishes" ADD CONSTRAINT "branch_dishes_restaurant_dish_id_fkey" FOREIGN KEY ("restaurant_dish_id") REFERENCES "restaurant_dishes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branch_drinks" ADD CONSTRAINT "branch_drinks_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "restaurant_branches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branch_drinks" ADD CONSTRAINT "branch_drinks_restaurant_drink_id_fkey" FOREIGN KEY ("restaurant_drink_id") REFERENCES "restaurant_drinks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dish_review" ADD CONSTRAINT "dish_review_dish_id_fkey" FOREIGN KEY ("dish_id") REFERENCES "branch_dishes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dish_review" ADD CONSTRAINT "dish_review_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "drink_review" ADD CONSTRAINT "drink_review_drink_id_fkey" FOREIGN KEY ("drink_id") REFERENCES "branch_drinks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "drink_review" ADD CONSTRAINT "drink_review_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branch_review" ADD CONSTRAINT "branch_review_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "restaurant_branches"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branch_review" ADD CONSTRAINT "branch_review_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_notifications" ADD CONSTRAINT "user_notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branch_notifications" ADD CONSTRAINT "branch_notifications_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "restaurant_branches"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "restaurant_branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment" ADD CONSTRAINT "payment_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment" ADD CONSTRAINT "payment_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_dish" ADD CONSTRAINT "order_dish_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_dish" ADD CONSTRAINT "order_dish_dish_id_fkey" FOREIGN KEY ("dish_id") REFERENCES "branch_dishes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_drinks" ADD CONSTRAINT "order_drinks_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_drinks" ADD CONSTRAINT "order_drinks_drink_id_fkey" FOREIGN KEY ("drink_id") REFERENCES "branch_drinks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "restaurant_branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branch_wallets" ADD CONSTRAINT "branch_wallets_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "restaurant_branches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branch_wallets" ADD CONSTRAINT "branch_wallets_restaurant_id_fkey" FOREIGN KEY ("restaurant_id") REFERENCES "restaurants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
