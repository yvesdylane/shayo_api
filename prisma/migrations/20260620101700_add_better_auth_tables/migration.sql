-- CreateTable
CREATE TABLE "ba_users" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "email_verified" BOOLEAN NOT NULL,
    "image" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ba_users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ba_sessions" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "ip_address" TEXT,
    "user_agent" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ba_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ba_accounts" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "account_id" TEXT NOT NULL,
    "provider_id" TEXT NOT NULL,
    "access_token" TEXT,
    "refresh_token" TEXT,
    "access_token_expires_at" TIMESTAMP(3),
    "refresh_token_expires_at" TIMESTAMP(3),
    "scope" TEXT,
    "id_token" TEXT,
    "password" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ba_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ba_verifications" (
    "id" TEXT NOT NULL,
    "identifier" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ba_verifications_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ba_users_email_key" ON "ba_users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "ba_sessions_token_key" ON "ba_sessions"("token");

-- AddForeignKey
ALTER TABLE "ba_sessions" ADD CONSTRAINT "ba_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "ba_users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ba_accounts" ADD CONSTRAINT "ba_accounts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "ba_users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
