# API Endpoints — Shayo

> Status legend: ⬜ Not started | 🟡 In progress | ✅ Done | 🔴 Blocked

---

## 1. Authentication (shared across all roles)

| # | Method | Path | Description | Role | Status | Completed by |
|---|--------|------|-------------|------|--------|-------------|
| 1 | POST | `/auth/register` | Create user account | Public | ⬜ | |
| 2 | POST | `/auth/login` | Login (returns JWT) | Public | ⬜ | |
| 3 | POST | `/auth/verify` | Verify email/phone with code | Public | ⬜ | |
| 4 | POST | `/auth/resend-code` | Resend verification code | Public | ⬜ | |
| 5 | POST | `/auth/forgot-password` | Request password reset | Public | ⬜ | |
| 6 | POST | `/auth/reset-password` | Reset password with token | Public | ⬜ | |
| 7 | GET | `/auth/me` | Get current user profile | All authenticated | ⬜ | |
| 8 | PATCH | `/auth/me` | Update own profile | All authenticated | ⬜ | |

---

## 2. Public / Browsing (shared — same path, same behavior)

| # | Method | Path | Description | Role | Status | Completed by |
|---|--------|------|-------------|------|--------|-------------|
| 9 | GET | `/restaurants` | List all verified restaurants | Public | ⬜ | |
| 10 | GET | `/restaurants/:id` | Restaurant details | Public | ⬜ | |
| 11 | GET | `/restaurants/:id/branches` | List restaurant branches | Public | ⬜ | |
| 12 | GET | `/branches/:id/menu` | Get branch menu (dishes + drinks) | Public | ⬜ | |

---

## 3. User Wallet & Points

| # | Method | Path | Description | Role | Status | Completed by |
|---|--------|------|-------------|------|--------|-------------|
| 13 | GET | `/wallet` | Get wallet + active special point grants | User | ⬜ | |
| 14 | POST | `/wallet/top-up` | Initiate mobile money top-up | User | ⬜ | |
| 15 | GET | `/wallet/transactions` | User's transaction history | User | ⬜ | |

---

## 4. User Orders

| # | Method | Path | Description | Role | Status | Completed by |
|---|--------|------|-------------|------|--------|-------------|
| 16 | POST | `/orders` | Place an order | User | ⬜ | |
| 17 | GET | `/orders` | Current user's orders | User | ⬜ | |
| 18 | GET | `/orders/:id` | Order details | User | ⬜ | |
| 19 | PATCH | `/orders/:id/cancel` | Cancel own order (if pending) | User | ⬜ | |

---

## 5. User Reviews

| # | Method | Path | Description | Role | Status | Completed by |
|---|--------|------|-------------|------|--------|-------------|
| 20 | POST | `/reviews/dish` | Review a dish from an order | User | ⬜ | |
| 21 | POST | `/reviews/drink` | Review a drink from an order | User | ⬜ | |
| 22 | POST | `/reviews/branch` | Review a branch | User | ⬜ | |
| 23 | GET | `/reviews` | Current user's reviews | User | ⬜ | |

---

## 6. User Notifications

| # | Method | Path | Description | Role | Status | Completed by |
|---|--------|------|-------------|------|--------|-------------|
| 24 | GET | `/notifications` | User's notifications | User | ⬜ | |
| 25 | PATCH | `/notifications/:id/read` | Mark notification as read | User | ⬜ | |

---

## 7. General Admin

| # | Method | Path | Description | Role | Status | Completed by |
|---|--------|------|-------------|------|--------|-------------|
| 26 | POST | `/admin/login` | Admin login | Admin | ⬜ | |
| 27 | GET | `/admin/dashboard` | Platform stats overview | Admin | ⬜ | |
| 28 | GET | `/admin/users` | List all users | Admin | ⬜ | |
| 29 | GET | `/admin/users/:id` | Get user details | Admin | ⬜ | |
| 30 | PATCH | `/admin/users/:id` | Update user (verify, ban, etc.) | Admin | ⬜ | |
| 31 | GET | `/admin/restaurants` | List all restaurants | Admin | ⬜ | |
| 32 | GET | `/admin/restaurants/:id` | Restaurant details | Admin | ⬜ | |
| 33 | POST | `/admin/restaurants` | Create restaurant | Admin | ⬜ | |
| 34 | PATCH | `/admin/restaurants/:id` | Update restaurant | Admin | ⬜ | |
| 35 | DELETE | `/admin/restaurants/:id` | Delete restaurant | Admin | ⬜ | |
| 36 | GET | `/admin/admins` | List platform admins | Admin | ⬜ | |
| 37 | POST | `/admin/admins` | Create platform admin | Admin | ⬜ | |
| 38 | DELETE | `/admin/admins/:id` | Remove platform admin | Admin | ⬜ | |
| 39 | GET | `/admin/transactions` | All transactions (filterable) | Admin | ⬜ | |
| 40 | PATCH | `/admin/transactions/:id/verify` | Verify a pending transaction | Admin | ⬜ | |
| 41 | GET | `/admin/payouts` | List pending payout requests | Admin | ⬜ | |
| 42 | POST | `/admin/payouts/:id/process` | Process (approve) a payout | Admin | ⬜ | |
| 43 | GET | `/admin/promotions` | List all promotions | Admin | ⬜ | |
| 44 | POST | `/admin/promotions` | Create a promotion | Admin | ⬜ | |
| 45 | PATCH | `/admin/promotions/:id` | Update a promotion | Admin | ⬜ | |
| 46 | DELETE | `/admin/promotions/:id` | Delete a promotion | Admin | ⬜ | |
| 47 | POST | `/admin/users/:id/grant-points` | Grant special points to a user | Admin | ⬜ | |
| 48 | POST | `/admin/users/grant-points-bulk` | Grant special points to multiple users | Admin | ⬜ | |
| 49 | PATCH | `/admin/system-settings` | Update system settings (rate, number) | Admin | ⬜ | |

---

## 8. Restaurant Admin

| # | Method | Path | Description | Role | Status | Completed by |
|---|--------|------|-------------|------|--------|-------------|
| 50 | GET | `/restaurant-admin/branches` | List own branches | Restaurant Admin | ⬜ | |
| 51 | POST | `/restaurant-admin/branches` | Create a branch | Restaurant Admin | ⬜ | |
| 52 | PATCH | `/restaurant-admin/branches/:id` | Update a branch | Restaurant Admin | ⬜ | |
| 53 | DELETE | `/restaurant-admin/branches/:id` | Delete a branch | Restaurant Admin | ⬜ | |
| 54 | GET | `/restaurant-admin/dishes` | List restaurant-level dishes | Restaurant Admin | ⬜ | |
| 55 | POST | `/restaurant-admin/dishes` | Add dish to restaurant menu | Restaurant Admin | ⬜ | |
| 56 | PATCH | `/restaurant-admin/dishes/:id` | Update dish price/availability | Restaurant Admin | ⬜ | |
| 57 | DELETE | `/restaurant-admin/dishes/:id` | Remove dish from restaurant menu | Restaurant Admin | ⬜ | |
| 58 | GET | `/restaurant-admin/drinks` | List restaurant-level drinks | Restaurant Admin | ⬜ | |
| 59 | POST | `/restaurant-admin/drinks` | Add drink to restaurant menu | Restaurant Admin | ⬜ | |
| 60 | PATCH | `/restaurant-admin/drinks/:id` | Update drink price/availability | Restaurant Admin | ⬜ | |
| 61 | DELETE | `/restaurant-admin/drinks/:id` | Remove drink from restaurant menu | Restaurant Admin | ⬜ | |
| 62 | GET | `/restaurant-admin/staff` | List restaurant staff | Restaurant Admin | ⬜ | |
| 63 | POST | `/restaurant-admin/staff` | Add staff to restaurant | Restaurant Admin | ⬜ | |
| 64 | PATCH | `/restaurant-admin/staff/:id` | Update staff role/branch | Restaurant Admin | ⬜ | |
| 65 | DELETE | `/restaurant-admin/staff/:id` | Remove staff | Restaurant Admin | ⬜ | |
| 66 | GET | `/restaurant-admin/orders` | Orders across all branches | Restaurant Admin | ⬜ | |
| 67 | GET | `/restaurant-admin/wallet` | Restaurant wallet overview | Restaurant Admin | ⬜ | |

---

## 9. Branch Admin

| # | Method | Path | Description | Role | Status | Completed by |
|---|--------|------|-------------|------|--------|-------------|
| 68 | GET | `/branch-admin/menu` | Branch menu (with overrides) | Branch Admin | ⬜ | |
| 69 | POST | `/branch-admin/dishes` | Override dish price/availability | Branch Admin | ⬜ | |
| 70 | PATCH | `/branch-admin/dishes/:id` | Update dish override | Branch Admin | ⬜ | |
| 71 | DELETE | `/branch-admin/dishes/:id` | Remove dish override | Branch Admin | ⬜ | |
| 72 | POST | `/branch-admin/drinks` | Override drink price/availability | Branch Admin | ⬜ | |
| 73 | PATCH | `/branch-admin/drinks/:id` | Update drink override | Branch Admin | ⬜ | |
| 74 | DELETE | `/branch-admin/drinks/:id` | Remove drink override | Branch Admin | ⬜ | |
| 75 | GET | `/branch-admin/orders` | Branch orders | Branch Admin | ⬜ | |
| 76 | GET | `/branch-admin/orders/:id` | Order details | Branch Admin | ⬜ | |
| 77 | PATCH | `/branch-admin/orders/:id/status` | Update order status (preparing → ready → delivered) | Branch Admin | ⬜ | |
| 78 | GET | `/branch-admin/reviews` | Branch reviews | Branch Admin | ⬜ | |
| 79 | GET | `/branch-admin/wallet` | Branch wallet balance | Branch Admin | ⬜ | |
| 80 | POST | `/branch-admin/payout-request` | Request a payout | Branch Admin | ⬜ | |
| 81 | GET | `/branch-admin/payout-requests` | Payout request history | Branch Admin | ⬜ | |
| 82 | GET | `/branch-admin/notifications` | Branch notifications | Branch Admin | ⬜ | |
| 83 | PATCH | `/branch-admin/notifications/:id/read` | Mark notification as read | Branch Admin | ⬜ | |

---

## Summary

| Role | Endpoint count |
|------|---------------|
| Public / Shared | 12 |
| User | 13 |
| General Admin | 24 |
| Restaurant Admin | 18 |
| Branch Admin | 16 |
| **Total** | **83** |
