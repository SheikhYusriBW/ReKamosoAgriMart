# ARCHITECTURE.md — ReKamoso AgriMart

> This file lives in the repo root. It is the single source of truth for any developer or AI coding tool working on this codebase. Read this first before making any changes.

---

## What This Is

ReKamoso AgriMart is a three-sided agricultural marketplace connecting horticultural **farmers** to retail **storefronts** in Botswana (expanding to Southern Africa). Farmers list produce, stores buy it. The platform supports three procurement modes: spot market, tenders, and contract farming.

**Current Phase:** Phase 1 — Farmer → Store platform only. Consumer-facing storefront and delivery logistics are Phase 2.

---

## Tech Stack

| Layer | Technology | Notes |
|---|---|---|
| Mobile App | Expo (React Native) + TypeScript | Single app, role-based (farmer + store). Runs on iOS, Android, and Web. |
| Admin Panel | Next.js + TypeScript + Tailwind CSS | Web only. Platform admin dashboard. |
| Backend | Supabase | PostgreSQL, Auth (phone OTP), real-time subscriptions, Edge Functions, Storage |
| Shared Code | TypeScript packages | Types, constants, utilities shared between mobile and admin |
| Push Notifications | Expo Notifications | Mobile push |
| WhatsApp Notifications | Twilio or Meta WhatsApp Business API | Via Supabase Edge Functions |
| Hosting (Admin) | Vercel | Next.js hosting |

---

## Monorepo Structure

```
rekamoso-agrimart/
├── apps/
│   ├── mobile/          # Expo app (Farmer + Store)
│   └── admin/           # Next.js admin panel
├── packages/
│   ├── shared/          # Shared types, constants, utils
│   └── supabase/        # Supabase client, queries, real-time
├── supabase/            # Migrations, seed data, Edge Functions
├── docs/                # Full planning documents
└── ARCHITECTURE.md      # ← You are here
```

**Full details:** See `docs/PROJECT_STRUCTURE.md`

---

## Database — 26 Tables

### Users & Auth
- `profiles` — base user profile (linked 1:1 to Supabase auth.users)
- `user_roles` — role assignments (farmer, store, admin). **Users can have multiple roles.**
- `farmers` — farmer-specific profile, verification status, aggregate ratings
- `farm_images` — farm photos
- `stores` — store-specific profile
- `admin_users` — admin access flags

### Product Catalogue
- `product_categories` — top-level categories (Fruits, Vegetables, Herbs, Leafy Greens)
- `products` — individual products within categories
- `product_varieties` — optional variety-level detail (e.g., Roma, Cherry tomatoes)
- `product_requests` — farmer requests to add new products (admin approves)
- `units_of_measure` — standardized units with context (farmer_to_store, store_to_consumer, both)

### Farmer Activity
- `farmer_products` — links farmers to products they grow
- `listings` — produce listings (spot market). **Has `quantity_remaining` requiring atomic updates.**
- `listing_images` — listing photos
- `cropping_plans` — what's planted, growth status, expected harvest dates

### Store Activity
- `tenders` — store procurement requests. **Has `quantity_fulfilled` requiring atomic updates.**
- `tender_offers` — farmer responses to tenders
- `contracts` — contract farming agreements
- `contract_deliveries` — individual delivery schedule entries against contracts

### Transactions
- `orders` — all orders (from spot, tender, or contract). Central transaction table.
- `order_items` — line items within orders

### Reviews & Ratings
- `reviews` — store reviews of farmers (overall, quality, reliability ratings)

### Notifications
- `notifications` — all notification records (push + WhatsApp)

### Platform
- `platform_settings` — key-value config (commission rate, feature flags)
- `currencies` — supported currencies (BWP active, ZAR seeded inactive)
- `countries` — countries the platform operates in (linked to default currency)

**Full schema:** See `docs/DATABASE_SCHEMA.md`

---

## Critical Implementation Patterns

### ⚠️ Atomic Quantity Updates (MUST FOLLOW)

`listings.quantity_remaining` and `tenders.quantity_fulfilled` are vulnerable to race conditions under concurrent access. **NEVER read-then-write from the client.**

**Required pattern — use Supabase RPC calling a PostgreSQL function:**

```sql
UPDATE listings
SET quantity_remaining = quantity_remaining - :ordered_qty,
    updated_at = NOW()
WHERE id = :listing_id
  AND quantity_remaining >= :ordered_qty
  AND status = 'active'
RETURNING quantity_remaining;
```

If the `WHERE` clause fails (not enough stock), 0 rows are updated and the order fails gracefully. This pattern applies to:
- `listings.quantity_remaining` — when placing orders
- `tenders.quantity_fulfilled` — when accepting farmer offers
- `contracts.total_delivered_qty` — when logging deliveries

### Authentication Flow

```
App opens → Check Supabase session
  → No session → Auth screens (phone + OTP)
  → Has session → Fetch user_roles
    → Single role → Route to farmer or store experience
    → Multiple roles → Show role switcher
    → Farmer with verification_status = 'pending' → Pending Approval screen
```

Auth uses **phone number + OTP** via Supabase Auth. Sessions stored in SecureStore on mobile.

### Multi-Role Support

Users can have multiple roles via the `user_roles` join table. A farming cooperative that also operates as a store gets both roles on one account. The app shows a role switcher when multiple active roles exist. Active role is managed in React Context (`RoleProvider`), not in the database.

### Multi-Store Architecture

Every store-related record has a `store_id`. When there's one store, all records share the same `store_id`. Adding a new store is just adding a database row. No code changes required.

- Farmer listings are visible to **all stores** (open marketplace)
- Orders, contracts, tenders, and inventory are scoped to individual stores via `store_id`
- Supabase RLS enforces data isolation

### Multi-Currency Support

Every table with a price field has a `currency_code` column (default: 'BWP'). Farmers and stores have a `country_id` linking to a country, which links to a default currency. The app formats prices using the currency symbol from the `currencies` table.

### Row Level Security (RLS)

Supabase RLS enforces data access:
- Farmers see their own data (listings, orders, contracts, plans)
- Stores see their own data (orders, tenders, contracts, inventory)
- Both see public data (active listings, farmer profiles, active tenders)
- Admins bypass RLS to see everything
- Users cannot modify their own roles (prevents privilege escalation)

### Offline-First (Lightweight)

Not using a full offline database (no WatermelonDB). Instead, a lightweight action queue using MMKV/AsyncStorage:

**Queue offline:** create/update cropping plans, create/update listings, order status updates (farmer side)
**Require online:** placing orders (needs real-time stock check), submitting tender offers

When connectivity returns, queued actions sync in order. Conflicts are shown to the user.

### Notification Strategy

Dual-channel: **push notifications** (Expo Notifications) + **WhatsApp** (Twilio/Meta API).

Notifications are triggered by Supabase Edge Functions on database events (new order, new listing, tender match, etc.). The `notifications` table stores all notification records for the in-app feed.

### Real-Time Subscriptions

Supabase real-time is used for:
- New notifications (badge count updates)
- New orders for farmers (dashboard refresh)
- Order status changes (both sides)
- New listings (store dashboard)
- New tender offers (store tender detail)
- Farmer approval status (pending screen auto-navigates on approval)

---

## Key Entities & Status Flows

### Farmer Verification
```
pending → approved → (suspended)
        → rejected → (can reapply → pending)
```

### Listing Status
```
draft → active → sold (quantity_remaining = 0)
              → expired (available_until passed)
              → cancelled (farmer deactivated)
```

### Order Status
```
new → accepted → preparing → ready → in_transit → delivered → confirmed
Any pre-delivered status → cancelled
```

### Payment Status
```
unpaid → paid → confirmed
```

### Tender Status
```
active → fulfilled (quantity_fulfilled >= quantity_needed)
       → expired (expires_at passed)
       → cancelled (store closed it)
```

### Tender Offer Status
```
pending → accepted → (creates order)
        → declined
```

### Contract Status
```
open (no farmer yet) → accepted (farmer accepted) → active (period started) → completed (period ended)
Any status → cancelled
```

### Contract Delivery Status
```
upcoming → due (date reached) → delivered (farmer logged) → confirmed (store confirmed)
                               → missed (past due, never delivered)
```

### Cropping Plan Growing Status
```
planted → growing → approaching_harvest → ready → harvested
```

---

## Navigation Structure

### Mobile App (Expo Router)

```
(auth)/              # Unauthenticated — login, register, OTP
(farmer)/            # Farmer role — tabs: Home | Listings | Marketplace | Orders | Profile
(store)/             # Store role — tabs: Home | Browse | Procurement | Orders | Profile
role-switcher        # Multi-role users switch between experiences
```

### Admin Panel (Next.js App Router)

```
/                    # Dashboard
/farmers             # Farmer management + applications
/stores              # Store management
/catalogue           # Products, categories, requests, units
/transactions        # Orders, contracts, tenders
/settings            # Platform config, currencies, countries
/analytics           # Basic reporting
```

---

## Screen Count

| Section | Count |
|---|---|
| Auth | 6 |
| Farmer | 16 |
| Store | 19 |
| Shared | 2 |
| Admin | 16 |
| **Total** | **59** |

**Full screen-by-screen breakdown:** See `docs/SCREEN_MAP.md`

---

## Data Layer Architecture

```
Screen (UI)
  ↓ calls
Hook (useListings, useOrders, etc.)
  ↓ calls
Service (listing.service.ts)
  ↓ calls
Supabase Query (packages/supabase/queries/listings.ts)
  ↓ calls
Supabase Client → PostgreSQL
```

- **Screens** handle UI rendering and user interaction
- **Hooks** manage state, loading, errors, and call services
- **Services** contain business logic and call Supabase queries
- **Queries** are the raw Supabase client calls (SELECT, INSERT, UPDATE, RPC)
- **Real-time subscriptions** are set up in hooks and update state automatically

---

## Revenue Model

Commission per transaction. The `orders` table captures `commission_rate` and `commission_amount` at order creation time (snapshot — immune to later rate changes). Commission rate is configurable via `platform_settings`. Exact rate TBD. Payment flows externally (cash/EFT) in Phase 1.

---

## Environment Variables

### Mobile (`apps/mobile/.env`)
```
EXPO_PUBLIC_SUPABASE_URL=
EXPO_PUBLIC_SUPABASE_ANON_KEY=
EXPO_PUBLIC_EXPO_PROJECT_ID=
EXPO_PUBLIC_DEFAULT_CURRENCY=BWP
EXPO_PUBLIC_DEFAULT_COUNTRY=BW
```

### Admin (`apps/admin/.env.local`)
```
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
NEXT_PUBLIC_DEFAULT_CURRENCY=BWP
```

### Edge Functions (`supabase/.env`)
```
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_WHATSAPP_NUMBER=
EXPO_ACCESS_TOKEN=
```

---

## Build Order (Phase 1)

```
 1. Supabase setup (migrations, seed, RLS)
 2. Shared types and constants
 3. Supabase queries package
 4. Auth flow (login, register, OTP, role routing)
 5. Farmer registration + admin approval
 6. Product catalogue + pickers
 7. Listings (CRUD + browse + order)
 8. Order management (full status flow)
 9. Cropping plans
10. Tenders (create, browse, offer, accept)
11. Contracts (create, accept, delivery tracking)
12. Reviews and ratings
13. Notifications (push + WhatsApp)
14. Admin panel
15. Polish (offline queue, error handling, edge cases)
```

---

## Naming Conventions

| Context | Convention | Example |
|---|---|---|
| Folders | kebab-case | `cropping-plans/` |
| Components | PascalCase | `ListingCard.tsx` |
| Hooks | camelCase + `use` | `useListings.ts` |
| Services | kebab-case + `.service.ts` | `listing.service.ts` |
| Constants | UPPER_SNAKE_CASE | `ORDER_STATUSES` |
| Types | PascalCase | `Listing`, `OrderStatus` |
| DB columns | snake_case | `quantity_remaining` |
| DB tables | snake_case plural | `tender_offers` |
| Env vars | UPPER_SNAKE_CASE | `EXPO_PUBLIC_SUPABASE_URL` |

---

## Phase Roadmap

**Phase 1 (Current):** Farmer → Store platform. Listings, tenders, contracts, orders, admin panel.

**Phase 2:** Store → Consumer app. Consumer catalogue, cart, checkout, 3PL delivery integration, payment gateway.

**Phase 3:** Scale. Multi-store consumer experience, farmer input marketplace, financing, advanced analytics, full offline-first.

---

## Full Documentation

| Document | Location | Contents |
|---|---|---|
| Project Brief | `docs/PROJECT_BRIEF.md` | Full feature specs, user flows, business logic |
| Database Schema | `docs/DATABASE_SCHEMA.md` | All 26 tables, columns, types, relationships, indexes, RLS, triggers |
| Project Structure | `docs/PROJECT_STRUCTURE.md` | Folder layout, file conventions, packages, env vars, dev workflow |
| Screen Map | `docs/SCREEN_MAP.md` | All 59 screens with data requirements, actions, navigation |
| Architecture | `ARCHITECTURE.md` | This file — condensed technical reference |

---

*Platform: ReKamoso AgriMart*
*Default currency: BWP (Botswana Pula)*
*Default country: Botswana*
*Last updated: February 2025*
