# ReKamoso AgriMart — Database Schema

## Farmer → Store Platform (Phase 1)

---

## Schema Overview

### Table Map

```
USERS & AUTH
├── profiles                  (base user profile — all users)
├── user_roles                (role assignments — a user can have multiple roles)
├── farmers                   (farmer-specific profile & verification)
├── stores                    (store-specific profile)
├── admin_users               (platform admin accounts)

PRODUCT CATALOGUE
├── product_categories        (Fruits, Vegetables, Herbs, Leafy Greens)
├── products                  (Tomatoes, Spinach, Basil, etc.)
├── product_varieties         (Roma, Cherry, Beef — optional detail)
├── product_requests          (farmer requests to add new products)
├── units_of_measure          (kg, tonne, crate, bunch, bag, each, g, pack)

FARMER ACTIVITY
├── farmer_products           (which products a farmer grows — links farmer to catalogue)
├── listings                  (farmer produce listings — spot market)
├── listing_images            (photos attached to listings)
├── cropping_plans            (what's planted, growth stage, harvest dates)

STORE ACTIVITY
├── tenders                   (store procurement requests)
├── tender_offers             (farmer responses/bids on tenders)
├── contracts                 (contract farming agreements)
├── contract_deliveries       (individual deliveries logged against a contract)

TRANSACTIONS
├── orders                    (all orders — from spot, tender, or contract)
├── order_items               (line items within an order)

REVIEWS & RATINGS
├── reviews                   (store reviews of farmer after delivery)

NOTIFICATIONS
├── notifications             (notification records for all users)

PLATFORM
├── platform_settings         (commission rate, global config)
├── currencies                (BWP, ZAR, KES — supported currencies)
├── countries                 (Botswana, South Africa — links to currency)
```

---

## Table Definitions

---

### 1. PROFILES

Base user profile linked to Supabase Auth. Every user (farmer, store operator, admin) has a profile.

| Column         | Type         | Constraints                    | Description                          |
|----------------|--------------|--------------------------------|--------------------------------------|
| id             | UUID         | PK, DEFAULT uuid_generate_v4() | Matches Supabase auth.users.id      |
| phone          | VARCHAR(20)  | NOT NULL, UNIQUE               | Phone number (used for OTP login)    |
| email          | VARCHAR(255) | UNIQUE, NULLABLE               | Optional email                       |
| full_name      | VARCHAR(255) | NOT NULL                       | Full name                            |
| avatar_url     | TEXT         | NULLABLE                       | Profile photo URL (Supabase Storage) |
| created_at     | TIMESTAMPTZ  | DEFAULT NOW()                  | Account creation date                |
| updated_at     | TIMESTAMPTZ  | DEFAULT NOW()                  | Last profile update                  |

**Notes:**
- `id` is the same UUID as Supabase `auth.users.id` — linked 1:1
- Roles are managed via the `user_roles` join table, NOT on this table
- A user can have multiple roles (e.g., farmer AND store operator)
- The app checks `user_roles` at login to determine which experience(s) to show
- If a user has multiple roles, the app displays a role switcher on the dashboard

---

### 2. USER_ROLES

Join table linking profiles to their roles. A user can have one or more roles.

| Column      | Type         | Constraints                    | Description                          |
|-------------|--------------|--------------------------------|--------------------------------------|
| id          | UUID         | PK, DEFAULT uuid_generate_v4() |                                     |
| profile_id  | UUID         | FK → profiles.id, NOT NULL     | The user                             |
| role        | VARCHAR(20)  | NOT NULL                       | 'farmer', 'store', 'admin'          |
| is_active   | BOOLEAN      | DEFAULT TRUE                   | Can deactivate a role without deleting |
| created_at  | TIMESTAMPTZ  | DEFAULT NOW()                  |                                      |

**Unique constraint:** (profile_id, role) — a user can only have each role once.

**Notes:**
- When a farmer registers, a row is added: (profile_id, 'farmer')
- When a store operator registers, a row is added: (profile_id, 'store')
- If an "Agri-preneur" or cooperative acts as both farmer and store, they get both roles on the same account
- Admins are assigned the 'admin' role by another admin
- The app queries this table at login to determine available experiences
- If a user has multiple active roles, the app shows a role switcher (e.g., "Switch to Store view" / "Switch to Farmer view")
- `is_active` allows temporarily disabling a role without removing it (e.g., suspending a farmer's selling ability while keeping their store role active)

---

### 3. FARMERS

Farmer-specific profile and verification data. Extends `profiles` for users with role = 'farmer'.

| Column              | Type         | Constraints                    | Description                              |
|---------------------|--------------|--------------------------------|------------------------------------------|
| id                  | UUID         | PK, DEFAULT uuid_generate_v4() | Farmer record ID                        |
| profile_id          | UUID         | FK → profiles.id, UNIQUE, NOT NULL | Link to base profile                |
| farm_name           | VARCHAR(255) | NOT NULL                       | Name of the farm                         |
| farm_location_lat   | DECIMAL(10,7)| NULLABLE                       | Farm GPS latitude                        |
| farm_location_lng   | DECIMAL(10,7)| NULLABLE                       | Farm GPS longitude                       |
| farm_address        | TEXT         | NULLABLE                       | Farm address (text/manual entry)         |
| country_id          | UUID         | FK → countries.id, NULLABLE    | Country where the farm is located        |
| farm_size           | VARCHAR(100) | NULLABLE                       | Farm size description (e.g., "5 hectares") |
| farm_size_unit      | VARCHAR(20)  | NULLABLE                       | 'hectares', 'acres', 'sqm'              |
| id_number           | VARCHAR(50)  | NULLABLE                       | National ID or business registration     |
| bio                 | TEXT         | NULLABLE                       | Short description of the farm            |
| verification_status | VARCHAR(20)  | NOT NULL, DEFAULT 'pending'    | 'pending', 'approved', 'rejected', 'suspended' |
| rejection_reason    | TEXT         | NULLABLE                       | Reason if rejected by admin              |
| verified_at         | TIMESTAMPTZ  | NULLABLE                       | Date admin approved                      |
| verified_by         | UUID         | FK → profiles.id, NULLABLE     | Admin who approved/rejected              |
| avg_overall_rating  | DECIMAL(3,2) | DEFAULT 0.00                   | Aggregate overall rating (1-5)           |
| avg_quality_rating  | DECIMAL(3,2) | DEFAULT 0.00                   | Aggregate quality rating (1-5)           |
| avg_reliability_rating | DECIMAL(3,2) | DEFAULT 0.00                | Aggregate reliability rating (1-5)       |
| total_reviews       | INTEGER      | DEFAULT 0                      | Total number of reviews received         |
| total_transactions  | INTEGER      | DEFAULT 0                      | Total completed orders                   |
| contract_fulfillment_rate | DECIMAL(5,2) | DEFAULT 0.00            | % of contracted volume delivered on time |
| created_at          | TIMESTAMPTZ  | DEFAULT NOW()                  |                                          |
| updated_at          | TIMESTAMPTZ  | DEFAULT NOW()                  |                                          |

**Notes:**
- Rating fields are **denormalized** (calculated from reviews table) for fast display. Updated via database trigger or Edge Function after each new review.
- `verification_status` gates all farmer actions — only 'approved' farmers can list, bid, or accept contracts.

---

### 4. FARM_IMAGES

Photos of the farm uploaded during registration or later.

| Column      | Type         | Constraints                    | Description                    |
|-------------|--------------|--------------------------------|--------------------------------|
| id          | UUID         | PK, DEFAULT uuid_generate_v4() |                                |
| farmer_id   | UUID         | FK → farmers.id, NOT NULL      | Which farmer's farm            |
| image_url   | TEXT         | NOT NULL                       | Supabase Storage URL           |
| is_primary  | BOOLEAN      | DEFAULT FALSE                  | Primary display image          |
| created_at  | TIMESTAMPTZ  | DEFAULT NOW()                  |                                |

---

### 5. STORES

Store-specific profile. Extends `profiles` for users with role = 'store'.

| Column            | Type         | Constraints                    | Description                            |
|-------------------|--------------|--------------------------------|----------------------------------------|
| id                | UUID         | PK, DEFAULT uuid_generate_v4() | Store record ID                       |
| profile_id        | UUID         | FK → profiles.id, UNIQUE, NOT NULL | Link to base profile              |
| business_name     | VARCHAR(255) | NOT NULL                       | Store / business name                  |
| store_type        | VARCHAR(50)  | NOT NULL                       | 'grocery', 'depo', 'restaurant', 'hotel', 'other' |
| location_lat      | DECIMAL(10,7)| NULLABLE                       | Store GPS latitude                     |
| location_lng      | DECIMAL(10,7)| NULLABLE                       | Store GPS longitude                    |
| address           | TEXT         | NULLABLE                       | Store address                          |
| country_id        | UUID         | FK → countries.id, NULLABLE    | Country where the store is located     |
| contact_phone     | VARCHAR(20)  | NULLABLE                       | Business phone (may differ from profile phone) |
| contact_email     | VARCHAR(255) | NULLABLE                       | Business email                         |
| bio               | TEXT         | NULLABLE                       | Short description of the store         |
| logo_url          | TEXT         | NULLABLE                       | Store logo (Supabase Storage)          |
| is_active         | BOOLEAN      | DEFAULT TRUE                   | Admin can deactivate                   |
| created_at        | TIMESTAMPTZ  | DEFAULT NOW()                  |                                        |
| updated_at        | TIMESTAMPTZ  | DEFAULT NOW()                  |                                        |

---

### 6. ADMIN_USERS

Lightweight table to flag which profiles have admin access. Used alongside the admin panel.

| Column      | Type         | Constraints                    | Description                    |
|-------------|--------------|--------------------------------|--------------------------------|
| id          | UUID         | PK, DEFAULT uuid_generate_v4() |                                |
| profile_id  | UUID         | FK → profiles.id, UNIQUE, NOT NULL | Link to base profile       |
| permissions | VARCHAR(20)  | DEFAULT 'full'                 | 'full', 'read_only' (future)  |
| created_at  | TIMESTAMPTZ  | DEFAULT NOW()                  |                                |

---

### 7. PRODUCT_CATEGORIES

Top-level product categories. Managed by admins.

| Column      | Type         | Constraints                    | Description                    |
|-------------|--------------|--------------------------------|--------------------------------|
| id          | UUID         | PK, DEFAULT uuid_generate_v4() |                                |
| name        | VARCHAR(100) | NOT NULL, UNIQUE               | e.g., 'Fruits', 'Vegetables'  |
| description | TEXT         | NULLABLE                       | Category description           |
| icon_url    | TEXT         | NULLABLE                       | Category icon (optional)       |
| sort_order  | INTEGER      | DEFAULT 0                      | Display ordering               |
| is_active   | BOOLEAN      | DEFAULT TRUE                   | Soft delete / hide             |
| created_at  | TIMESTAMPTZ  | DEFAULT NOW()                  |                                |
| updated_at  | TIMESTAMPTZ  | DEFAULT NOW()                  |                                |

**Seed data:** Fruits, Vegetables, Herbs, Leafy Greens

---

### 8. PRODUCTS

Individual products within categories. Managed by admins. Farmers select from this list.

| Column      | Type         | Constraints                    | Description                         |
|-------------|--------------|--------------------------------|-------------------------------------|
| id          | UUID         | PK, DEFAULT uuid_generate_v4() |                                    |
| category_id | UUID         | FK → product_categories.id, NOT NULL | Parent category              |
| name        | VARCHAR(100) | NOT NULL                       | e.g., 'Tomatoes', 'Spinach'        |
| description | TEXT         | NULLABLE                       | Product description                 |
| image_url   | TEXT         | NULLABLE                       | Default product image               |
| sort_order  | INTEGER      | DEFAULT 0                      | Display ordering within category    |
| is_active   | BOOLEAN      | DEFAULT TRUE                   | Soft delete / hide                  |
| created_at  | TIMESTAMPTZ  | DEFAULT NOW()                  |                                     |
| updated_at  | TIMESTAMPTZ  | DEFAULT NOW()                  |                                     |

**Unique constraint:** (category_id, name) — no duplicate product names within a category.

**Seed data:**
- Fruits: Tomatoes, Apples, Oranges, Bananas, Grapes, Mangoes, Avocados, Peaches, Berries, Watermelon, Lemons
- Vegetables: Cabbage, Onions, Potatoes, Butternut, Carrots, Green Beans, Peppers, Broccoli, Lettuce, Beetroot
- Herbs: Parsley, Coriander, Basil, Mint, Rosemary
- Leafy Greens: Spinach, Kale, Swiss Chard, Rocket, Baby Spinach

---

### 9. PRODUCT_VARIETIES

Optional variety-level detail within a product. E.g., Tomatoes → Roma, Cherry, Beef.

| Column      | Type         | Constraints                    | Description                    |
|-------------|--------------|--------------------------------|--------------------------------|
| id          | UUID         | PK, DEFAULT uuid_generate_v4() |                                |
| product_id  | UUID         | FK → products.id, NOT NULL     | Parent product                 |
| name        | VARCHAR(100) | NOT NULL                       | e.g., 'Roma', 'Cherry'        |
| description | TEXT         | NULLABLE                       |                                |
| is_active   | BOOLEAN      | DEFAULT TRUE                   |                                |
| created_at  | TIMESTAMPTZ  | DEFAULT NOW()                  |                                |

**Unique constraint:** (product_id, name)

---

### 10. PRODUCT_REQUESTS

Farmer requests to add a product not in the catalogue.

| Column         | Type         | Constraints                    | Description                          |
|----------------|--------------|--------------------------------|--------------------------------------|
| id             | UUID         | PK, DEFAULT uuid_generate_v4() |                                     |
| farmer_id      | UUID         | FK → farmers.id, NOT NULL      | Farmer who requested                 |
| product_name   | VARCHAR(100) | NOT NULL                       | Suggested product name               |
| suggested_category_id | UUID  | FK → product_categories.id, NULLABLE | Suggested category            |
| description    | TEXT         | NULLABLE                       | Farmer's description of the product  |
| status         | VARCHAR(20)  | NOT NULL, DEFAULT 'pending'    | 'pending', 'approved', 'rejected'    |
| admin_notes    | TEXT         | NULLABLE                       | Admin response / reason for rejection|
| reviewed_by    | UUID         | FK → profiles.id, NULLABLE     | Admin who reviewed                   |
| reviewed_at    | TIMESTAMPTZ  | NULLABLE                       |                                      |
| created_product_id | UUID     | FK → products.id, NULLABLE     | If approved, link to created product |
| created_at     | TIMESTAMPTZ  | DEFAULT NOW()                  |                                      |

---

### 11. UNITS_OF_MEASURE

Standardized units. Stored as a table so admins can add/edit without code changes.

| Column      | Type         | Constraints                    | Description                              |
|-------------|--------------|--------------------------------|------------------------------------------|
| id          | UUID         | PK, DEFAULT uuid_generate_v4() |                                         |
| name        | VARCHAR(50)  | NOT NULL, UNIQUE               | e.g., 'Kilogram', 'Tonne', 'Crate'      |
| abbreviation| VARCHAR(10)  | NOT NULL, UNIQUE               | e.g., 'kg', 't', 'crate'                |
| context     | VARCHAR(20)  | NOT NULL                       | 'farmer_to_store', 'store_to_consumer', 'both' |
| sort_order  | INTEGER      | DEFAULT 0                      | Display ordering                         |
| is_active   | BOOLEAN      | DEFAULT TRUE                   |                                          |
| created_at  | TIMESTAMPTZ  | DEFAULT NOW()                  |                                          |

**Seed data:**

| name      | abbreviation | context            |
|-----------|--------------|--------------------|
| Kilogram  | kg           | both               |
| Tonne     | t            | farmer_to_store    |
| Crate     | crate        | farmer_to_store    |
| Bunch     | bunch        | both               |
| Bag       | bag          | farmer_to_store    |
| Each      | each         | both               |
| Gram      | g            | store_to_consumer  |
| Pack      | pack         | store_to_consumer  |

---

### 12. FARMER_PRODUCTS

Links a farmer to the products they grow. Used for matching tenders, contracts, and filtering.

| Column      | Type         | Constraints                    | Description                    |
|-------------|--------------|--------------------------------|--------------------------------|
| id          | UUID         | PK, DEFAULT uuid_generate_v4() |                                |
| farmer_id   | UUID         | FK → farmers.id, NOT NULL      |                                |
| product_id  | UUID         | FK → products.id, NOT NULL     |                                |
| created_at  | TIMESTAMPTZ  | DEFAULT NOW()                  |                                |

**Unique constraint:** (farmer_id, product_id) — a farmer can only link to a product once.

---

### 13. LISTINGS

Farmer produce listings for the spot market. The core of the marketplace.

| Column              | Type          | Constraints                    | Description                              |
|---------------------|---------------|--------------------------------|------------------------------------------|
| id                  | UUID          | PK, DEFAULT uuid_generate_v4() |                                         |
| farmer_id           | UUID          | FK → farmers.id, NOT NULL      | Farmer who listed                        |
| product_id          | UUID          | FK → products.id, NOT NULL     | Product being sold                       |
| variety_id          | UUID          | FK → product_varieties.id, NULLABLE | Specific variety (optional)         |
| title               | VARCHAR(255)  | NULLABLE                       | Optional custom title for the listing    |
| description         | TEXT          | NULLABLE                       | Additional details, notes                |
| quantity            | DECIMAL(12,2) | NOT NULL                       | Total quantity available                 |
| quantity_remaining  | DECIMAL(12,2) | NOT NULL                       | Quantity not yet claimed by orders       |
| unit_id             | UUID          | FK → units_of_measure.id, NOT NULL | Unit of measure                      |
| price_per_unit      | DECIMAL(12,2) | NOT NULL                       | Price per unit                           |
| currency_code       | VARCHAR(3)    | NOT NULL, DEFAULT 'BWP'        | Currency (ISO 4217). FK → currencies.code |
| quality_grade       | VARCHAR(20)   | NULLABLE                       | 'A', 'B', 'C' or free text              |
| available_from      | DATE          | NOT NULL                       | Start of availability window             |
| available_until     | DATE          | NOT NULL                       | End of availability window               |
| delivery_options    | VARCHAR(20)   | NOT NULL, DEFAULT 'either'     | 'farmer_delivers', 'store_collects', 'either' |
| status              | VARCHAR(20)   | NOT NULL, DEFAULT 'active'     | 'draft', 'active', 'sold', 'expired', 'cancelled' |
| created_at          | TIMESTAMPTZ   | DEFAULT NOW()                  |                                          |
| updated_at          | TIMESTAMPTZ   | DEFAULT NOW()                  |                                          |

**Notes:**
- `quantity_remaining` starts equal to `quantity` and decreases as orders are placed
- When `quantity_remaining` = 0, status auto-updates to 'sold'
- When `available_until` passes and quantity remains, status auto-updates to 'expired'
- Expired/sold listings are archived, not deleted

**⚠️ CRITICAL — Concurrency / Race Condition Handling:**

`quantity_remaining` MUST be updated using atomic database operations, never read-then-write from the client. If two stores click "Buy" simultaneously on the same listing, a naive approach will oversell.

**Required pattern — use PostgreSQL atomic update:**

```sql
-- This is the ONLY safe way to decrement quantity
UPDATE listings
SET quantity_remaining = quantity_remaining - :ordered_qty,
    updated_at = NOW()
WHERE id = :listing_id
  AND quantity_remaining >= :ordered_qty
  AND status = 'active'
RETURNING quantity_remaining;
```

**Why this works:**
- PostgreSQL row-level locking ensures only one transaction modifies the row at a time
- The `WHERE quantity_remaining >= :ordered_qty` check happens atomically — if there's not enough stock, the update affects 0 rows and returns nothing
- The app checks if `RETURNING` gave a result — if not, the stock was insufficient and the order fails gracefully
- **NEVER** do this from the client: `read quantity → check if enough → write new quantity` — this WILL cause overselling under concurrent load

**This same atomic pattern applies to:**
- `tenders.quantity_fulfilled` — when accepting farmer offers
- `contracts.total_delivered_qty` — when logging contract deliveries
- Any other field that multiple users might update simultaneously

---

### 14. LISTING_IMAGES

Photos attached to a listing.

| Column      | Type         | Constraints                    | Description                    |
|-------------|--------------|--------------------------------|--------------------------------|
| id          | UUID         | PK, DEFAULT uuid_generate_v4() |                                |
| listing_id  | UUID         | FK → listings.id, NOT NULL     |                                |
| image_url   | TEXT         | NOT NULL                       | Supabase Storage URL           |
| sort_order  | INTEGER      | DEFAULT 0                      | Display ordering               |
| created_at  | TIMESTAMPTZ  | DEFAULT NOW()                  |                                |

---

### 15. CROPPING_PLANS

Farmer's planting and growth records. Provides forward visibility for stores.

| Column              | Type          | Constraints                    | Description                                   |
|---------------------|---------------|--------------------------------|-----------------------------------------------|
| id                  | UUID          | PK, DEFAULT uuid_generate_v4() |                                              |
| farmer_id           | UUID          | FK → farmers.id, NOT NULL      | Farmer who owns this plan                     |
| product_id          | UUID          | FK → products.id, NOT NULL     | What's being grown                            |
| variety_id          | UUID          | FK → product_varieties.id, NULLABLE | Specific variety (optional)              |
| date_planted        | DATE          | NOT NULL                       | When the crop was planted                     |
| expected_harvest_date | DATE        | NOT NULL                       | When harvest is expected                      |
| estimated_yield     | DECIMAL(12,2) | NULLABLE                       | Expected quantity                             |
| yield_unit_id       | UUID          | FK → units_of_measure.id, NULLABLE | Unit for estimated yield                  |
| actual_yield        | DECIMAL(12,2) | NULLABLE                       | Actual quantity harvested (filled after harvest) |
| growing_status      | VARCHAR(30)   | NOT NULL, DEFAULT 'planted'    | 'planted', 'growing', 'approaching_harvest', 'ready', 'harvested' |
| is_contracted       | BOOLEAN       | DEFAULT FALSE                  | Whether this crop is committed to a contract  |
| contract_id         | UUID          | FK → contracts.id, NULLABLE    | Link to contract if committed                 |
| notes               | TEXT          | NULLABLE                       | Farmer notes (e.g., weather issues)           |
| created_at          | TIMESTAMPTZ   | DEFAULT NOW()                  |                                               |
| updated_at          | TIMESTAMPTZ   | DEFAULT NOW()                  |                                               |

**Notes:**
- Stores can browse all cropping plans to see forward supply
- Contracted plans are flagged and linked to a specific contract/store
- Status can be updated by the farmer as the crop progresses
- Platform can trigger reminders based on `expected_harvest_date`

---

### 16. TENDERS

Store procurement requests. Stores broadcast what they need and farmers respond.

| Column             | Type          | Constraints                    | Description                             |
|--------------------|---------------|--------------------------------|-----------------------------------------|
| id                 | UUID          | PK, DEFAULT uuid_generate_v4() |                                        |
| store_id           | UUID          | FK → stores.id, NOT NULL       | Store posting the tender                |
| product_id         | UUID          | FK → products.id, NOT NULL     | Product needed                          |
| variety_id         | UUID          | FK → product_varieties.id, NULLABLE | Specific variety needed (optional) |
| quantity_needed    | DECIMAL(12,2) | NOT NULL                       | How much the store needs                |
| unit_id            | UUID          | FK → units_of_measure.id, NOT NULL | Unit of measure                     |
| min_price          | DECIMAL(12,2) | NULLABLE                       | Minimum price store is willing to pay   |
| max_price          | DECIMAL(12,2) | NULLABLE                       | Maximum price store is willing to pay   |
| currency_code      | VARCHAR(3)    | NOT NULL, DEFAULT 'BWP'        | Currency (ISO 4217). FK → currencies.code |
| date_needed_by     | DATE          | NOT NULL                       | When the store needs the produce by     |
| quality_requirements | TEXT        | NULLABLE                       | Quality standards / description         |
| delivery_preference| VARCHAR(20)   | DEFAULT 'either'               | 'farmer_delivers', 'store_collects', 'either' |
| quantity_fulfilled | DECIMAL(12,2) | DEFAULT 0.00                   | Total quantity from accepted offers     |
| status             | VARCHAR(20)   | NOT NULL, DEFAULT 'active'     | 'active', 'fulfilled', 'expired', 'cancelled' |
| expires_at         | TIMESTAMPTZ   | NULLABLE                       | When the tender auto-expires            |
| created_at         | TIMESTAMPTZ   | DEFAULT NOW()                  |                                         |
| updated_at         | TIMESTAMPTZ   | DEFAULT NOW()                  |                                         |

**Notes:**
- Price range is optional — store can leave it open for farmer offers
- `quantity_fulfilled` tracks how much has been accepted from farmer offers
- When `quantity_fulfilled` >= `quantity_needed`, status auto-updates to 'fulfilled'
- Notifications sent to all farmers who grow the requested product
- **⚠️ Concurrency:** `quantity_fulfilled` must use the same atomic update pattern as `listings.quantity_remaining` (see Listings table concurrency note). Multiple farmer offers being accepted simultaneously must not over-fulfill the tender.

---

### 17. TENDER_OFFERS

Farmer responses/bids on store tenders.

| Column         | Type          | Constraints                    | Description                          |
|----------------|---------------|--------------------------------|--------------------------------------|
| id             | UUID          | PK, DEFAULT uuid_generate_v4() |                                     |
| tender_id      | UUID          | FK → tenders.id, NOT NULL      | Which tender this offer is for       |
| farmer_id      | UUID          | FK → farmers.id, NOT NULL      | Farmer making the offer              |
| quantity_offered | DECIMAL(12,2) | NOT NULL                     | How much the farmer can supply       |
| price_per_unit | DECIMAL(12,2) | NOT NULL                       | Farmer's offered price per unit      |
| currency_code  | VARCHAR(3)    | NOT NULL, DEFAULT 'BWP'        | Currency (ISO 4217). FK → currencies.code |
| delivery_date  | DATE          | NOT NULL                       | When the farmer can deliver          |
| delivery_method| VARCHAR(20)   | DEFAULT 'either'               | 'farmer_delivers', 'store_collects', 'either' |
| notes          | TEXT          | NULLABLE                       | Additional details from farmer       |
| status         | VARCHAR(20)   | NOT NULL, DEFAULT 'pending'    | 'pending', 'accepted', 'declined'    |
| responded_at   | TIMESTAMPTZ   | NULLABLE                       | When store accepted/declined         |
| created_at     | TIMESTAMPTZ   | DEFAULT NOW()                  |                                      |

**Notes:**
- A farmer can only submit one offer per tender (unique constraint: tender_id + farmer_id)
- When accepted, an order is created from this offer
- Store can accept multiple offers on one tender (from different farmers)

---

### 18. CONTRACTS

Contract farming agreements between a store and a farmer.

| Column              | Type          | Constraints                    | Description                                |
|---------------------|---------------|--------------------------------|--------------------------------------------|
| id                  | UUID          | PK, DEFAULT uuid_generate_v4() |                                           |
| store_id            | UUID          | FK → stores.id, NOT NULL       | Store offering the contract                |
| farmer_id           | UUID          | FK → farmers.id, NULLABLE      | Farmer (NULL until a farmer accepts)       |
| product_id          | UUID          | FK → products.id, NOT NULL     | Contracted crop                            |
| variety_id          | UUID          | FK → product_varieties.id, NULLABLE | Specific variety (optional)           |
| quantity_per_delivery | DECIMAL(12,2) | NOT NULL                     | Required quantity per delivery cycle       |
| unit_id             | UUID          | FK → units_of_measure.id, NOT NULL | Unit of measure                        |
| price_per_unit      | DECIMAL(12,2) | NOT NULL                       | Agreed price per unit (fixed for duration) |
| currency_code       | VARCHAR(3)    | NOT NULL, DEFAULT 'BWP'        | Currency (ISO 4217). FK → currencies.code  |
| delivery_frequency  | VARCHAR(20)   | NOT NULL                       | 'weekly', 'biweekly', 'monthly', 'custom' |
| custom_frequency_days | INTEGER     | NULLABLE                       | If 'custom', number of days between deliveries |
| quality_standards   | TEXT          | NULLABLE                       | Quality requirements                       |
| payment_terms       | VARCHAR(50)   | NULLABLE                       | 'on_delivery', 'weekly', 'monthly'         |
| start_date          | DATE          | NOT NULL                       | Contract start                             |
| end_date            | DATE          | NOT NULL                       | Contract end                               |
| total_contracted_qty | DECIMAL(12,2) | NULLABLE                      | Calculated total over contract period      |
| total_delivered_qty | DECIMAL(12,2) | DEFAULT 0.00                   | Running total of all deliveries            |
| fulfillment_rate    | DECIMAL(5,2)  | DEFAULT 0.00                   | % of contracted volume delivered           |
| status              | VARCHAR(20)   | NOT NULL, DEFAULT 'open'       | 'open', 'accepted', 'active', 'completed', 'cancelled' |
| is_public           | BOOLEAN       | DEFAULT TRUE                   | TRUE = visible to all eligible farmers, FALSE = sent to specific farmer |
| created_at          | TIMESTAMPTZ   | DEFAULT NOW()                  |                                            |
| updated_at          | TIMESTAMPTZ   | DEFAULT NOW()                  |                                            |

**Contract states:**

```
open       → published, waiting for farmer to accept (farmer_id is NULL)
accepted   → farmer has accepted, contract not yet started (start_date in future)
active     → contract period is underway, deliveries expected
completed  → end_date has passed, contract fulfilled
cancelled  → cancelled by either party before completion
```

**Notes:**
- `farmer_id` is NULL when contract is first published (open to multiple farmers)
- Once a farmer accepts, `farmer_id` is set and status moves to 'accepted'
- `total_delivered_qty` and `fulfillment_rate` are updated after each contract delivery
- Contracted crops show up flagged in the farmer's cropping plan

---

### 19. CONTRACT_DELIVERIES

Individual deliveries logged against an active contract.

| Column             | Type          | Constraints                    | Description                              |
|--------------------|---------------|--------------------------------|------------------------------------------|
| id                 | UUID          | PK, DEFAULT uuid_generate_v4() |                                         |
| contract_id        | UUID          | FK → contracts.id, NOT NULL    | Parent contract                          |
| expected_date      | DATE          | NOT NULL                       | When this delivery was due               |
| actual_date        | DATE          | NULLABLE                       | When the delivery actually happened      |
| expected_quantity  | DECIMAL(12,2) | NOT NULL                       | Contracted quantity for this delivery    |
| actual_quantity    | DECIMAL(12,2) | NULLABLE                       | Actual quantity delivered                |
| status             | VARCHAR(20)   | NOT NULL, DEFAULT 'upcoming'   | 'upcoming', 'due', 'delivered', 'confirmed', 'missed' |
| farmer_notes       | TEXT          | NULLABLE                       | Farmer notes on this delivery            |
| store_notes        | TEXT          | NULLABLE                       | Store notes on receipt                   |
| quality_rating     | INTEGER       | NULLABLE, CHECK (1-5)          | Store rates quality of this delivery     |
| order_id           | UUID          | FK → orders.id, NULLABLE       | Link to the order created for this delivery |
| created_at         | TIMESTAMPTZ   | DEFAULT NOW()                  |                                          |
| updated_at         | TIMESTAMPTZ   | DEFAULT NOW()                  |                                          |

**Delivery states:**

```
upcoming   → delivery date is in the future
due        → delivery date is today or has passed without delivery
delivered  → farmer has logged the delivery
confirmed  → store has confirmed receipt
missed     → delivery was never made (past due, undelivered)
```

**Notes:**
- Contract deliveries are auto-generated based on `delivery_frequency` and contract date range
- Platform sends reminders when a delivery is approaching or due
- `actual_quantity` vs `expected_quantity` variance feeds into contract fulfillment tracking
- Each delivery can create an order record (linked via `order_id`)

---

### 20. ORDERS

All orders regardless of source (spot market, tender, contract). This is the central transaction table.

| Column             | Type          | Constraints                    | Description                              |
|--------------------|---------------|--------------------------------|------------------------------------------|
| id                 | UUID          | PK, DEFAULT uuid_generate_v4() |                                         |
| order_number       | VARCHAR(20)   | NOT NULL, UNIQUE               | Human-readable order number (e.g., ORD-00001) |
| store_id           | UUID          | FK → stores.id, NOT NULL       | Store placing the order                  |
| farmer_id          | UUID          | FK → farmers.id, NOT NULL      | Farmer fulfilling the order              |
| source             | VARCHAR(20)   | NOT NULL                       | 'spot', 'tender', 'contract'             |
| listing_id         | UUID          | FK → listings.id, NULLABLE     | If source = 'spot', the listing          |
| tender_offer_id    | UUID          | FK → tender_offers.id, NULLABLE | If source = 'tender', the accepted offer |
| contract_delivery_id | UUID        | FK → contract_deliveries.id, NULLABLE | If source = 'contract', the delivery  |
| delivery_method    | VARCHAR(20)   | NOT NULL                       | 'farmer_delivers', 'store_collects', 'third_party' |
| delivery_date      | DATE          | NULLABLE                       | Expected delivery/collection date        |
| delivery_address   | TEXT          | NULLABLE                       | Delivery destination (if farmer delivers)|
| pickup_address     | TEXT          | NULLABLE                       | Pickup location (if store collects)      |
| subtotal           | DECIMAL(12,2) | NOT NULL                       | Total value of order items               |
| currency_code      | VARCHAR(3)    | NOT NULL, DEFAULT 'BWP'        | Currency (ISO 4217). FK → currencies.code |
| commission_rate    | DECIMAL(5,2)  | DEFAULT 0.00                   | Commission % at time of order            |
| commission_amount  | DECIMAL(12,2) | DEFAULT 0.00                   | Calculated commission amount             |
| status             | VARCHAR(20)   | NOT NULL, DEFAULT 'new'        | See status flow below                    |
| payment_status     | VARCHAR(20)   | DEFAULT 'unpaid'               | 'unpaid', 'paid', 'confirmed'            |
| payment_method     | VARCHAR(20)   | NULLABLE                       | 'cash', 'eft'                            |
| actual_qty_received | DECIMAL(12,2)| NULLABLE                       | Actual total quantity store received     |
| store_notes        | TEXT          | NULLABLE                       | Store notes on receipt                   |
| farmer_notes       | TEXT          | NULLABLE                       | Farmer notes on the order                |
| created_at         | TIMESTAMPTZ   | DEFAULT NOW()                  |                                          |
| updated_at         | TIMESTAMPTZ   | DEFAULT NOW()                  |                                          |

**Order status flow:**

```
new → accepted → preparing → ready → in_transit → delivered → confirmed
                                                        ↓
                                                   cancelled (can happen at any stage before delivered)
```

**Notes:**
- `commission_rate` and `commission_amount` are captured at order creation time (snapshot — even if platform rate changes later, the order retains the rate at the time)
- `source` field links back to where this order originated for traceability
- Only one of `listing_id`, `tender_offer_id`, or `contract_delivery_id` will be populated per order

---

### 21. ORDER_ITEMS

Line items within an order. An order can contain multiple products (especially from tenders or if we later allow multi-product orders).

| Column         | Type          | Constraints                    | Description                          |
|----------------|---------------|--------------------------------|--------------------------------------|
| id             | UUID          | PK, DEFAULT uuid_generate_v4() |                                     |
| order_id       | UUID          | FK → orders.id, NOT NULL       | Parent order                         |
| product_id     | UUID          | FK → products.id, NOT NULL     | Product                              |
| variety_id     | UUID          | FK → product_varieties.id, NULLABLE | Variety (optional)              |
| quantity       | DECIMAL(12,2) | NOT NULL                       | Ordered quantity                     |
| unit_id        | UUID          | FK → units_of_measure.id, NOT NULL | Unit of measure                  |
| price_per_unit | DECIMAL(12,2) | NOT NULL                       | Agreed price per unit                |
| currency_code  | VARCHAR(3)    | NOT NULL, DEFAULT 'BWP'        | Currency (ISO 4217). FK → currencies.code |
| line_total     | DECIMAL(12,2) | NOT NULL                       | quantity × price_per_unit            |
| actual_qty_received | DECIMAL(12,2) | NULLABLE                  | What the store actually received     |
| quality_notes  | TEXT          | NULLABLE                       | Store notes on quality of this item  |
| created_at     | TIMESTAMPTZ   | DEFAULT NOW()                  |                                      |

---

### 22. REVIEWS

Store reviews of farmers after completed deliveries.

| Column             | Type         | Constraints                    | Description                          |
|--------------------|--------------|--------------------------------|--------------------------------------|
| id                 | UUID         | PK, DEFAULT uuid_generate_v4() |                                     |
| order_id           | UUID         | FK → orders.id, NOT NULL, UNIQUE | One review per order              |
| store_id           | UUID         | FK → stores.id, NOT NULL       | Store leaving the review             |
| farmer_id          | UUID         | FK → farmers.id, NOT NULL      | Farmer being reviewed                |
| overall_rating     | INTEGER      | NOT NULL, CHECK (1-5)          | Overall experience                   |
| quality_rating     | INTEGER      | NOT NULL, CHECK (1-5)          | Produce quality                      |
| reliability_rating | INTEGER      | NOT NULL, CHECK (1-5)          | On-time, correct quantities          |
| comment            | TEXT         | NULLABLE                       | Written review                       |
| created_at         | TIMESTAMPTZ  | DEFAULT NOW()                  |                                      |

**Notes:**
- One review per order (unique constraint on `order_id`)
- After a review is created, a trigger or Edge Function recalculates the farmer's aggregate ratings in the `farmers` table
- Reviews are visible on the farmer's public profile to all stores

---

### 23. NOTIFICATIONS

Record of all notifications sent. Used for in-app notification feed and tracking delivery status of push/WhatsApp notifications.

| Column         | Type         | Constraints                    | Description                              |
|----------------|--------------|--------------------------------|------------------------------------------|
| id             | UUID         | PK, DEFAULT uuid_generate_v4() |                                         |
| recipient_id   | UUID         | FK → profiles.id, NOT NULL     | User receiving the notification          |
| type           | VARCHAR(50)  | NOT NULL                       | Notification type (see list below)       |
| title          | VARCHAR(255) | NOT NULL                       | Notification title                       |
| body           | TEXT         | NOT NULL                       | Notification body text                   |
| data           | JSONB        | NULLABLE                       | Additional data payload (e.g., order_id, listing_id) |
| channel        | VARCHAR(20)  | NOT NULL                       | 'push', 'whatsapp', 'both'              |
| is_read        | BOOLEAN      | DEFAULT FALSE                  | Has the user seen this in-app            |
| push_sent      | BOOLEAN      | DEFAULT FALSE                  | Was push notification sent successfully  |
| whatsapp_sent  | BOOLEAN      | DEFAULT FALSE                  | Was WhatsApp message sent successfully   |
| created_at     | TIMESTAMPTZ  | DEFAULT NOW()                  |                                          |

**Notification types:**

```
FARMER NOTIFICATIONS:
- farmer_approved
- farmer_rejected
- new_tender_match
- contract_offer_received
- order_placed_on_listing
- order_status_changed
- contract_delivery_reminder
- product_request_approved
- product_request_rejected
- review_received
- harvest_reminder

STORE NOTIFICATIONS:
- new_listing_match
- tender_offer_received
- order_status_changed
- contract_delivery_reminder
- delivery_confirmation_prompt
- contract_fulfillment_alert
- new_farmer_in_area
```

---

### 24. PLATFORM_SETTINGS

Global platform configuration. Key-value store for settings.

| Column      | Type         | Constraints                    | Description                    |
|-------------|--------------|--------------------------------|--------------------------------|
| id          | UUID         | PK, DEFAULT uuid_generate_v4() |                                |
| key         | VARCHAR(100) | NOT NULL, UNIQUE               | Setting key                    |
| value       | TEXT         | NOT NULL                       | Setting value                  |
| description | TEXT         | NULLABLE                       | What this setting controls     |
| updated_at  | TIMESTAMPTZ  | DEFAULT NOW()                  |                                |
| updated_by  | UUID         | FK → profiles.id, NULLABLE     | Admin who last updated         |

**Seed data:**

| key                    | value | description                              |
|------------------------|-------|------------------------------------------|
| commission_rate        | 0     | Commission percentage (0-100). TBD.      |
| platform_name          | ReKamoso AgriMart | Platform display name          |
| support_phone          |       | Platform support phone number            |
| support_email          |       | Platform support email                   |
| farmer_approval_required | true | Whether farmer registration requires admin approval |
| default_currency         | BWP  | Default currency code for the platform              |
| default_country          | BW   | Default country code (ISO 3166-1 alpha-2)           |

---

### 25. CURRENCIES

Supported currencies on the platform. Allows multi-country expansion without code changes.

| Column            | Type         | Constraints                    | Description                          |
|-------------------|--------------|--------------------------------|--------------------------------------|
| id                | UUID         | PK, DEFAULT uuid_generate_v4() |                                     |
| code              | VARCHAR(3)   | NOT NULL, UNIQUE               | ISO 4217 currency code (e.g., 'BWP', 'ZAR') |
| name              | VARCHAR(100) | NOT NULL                       | Full name (e.g., 'Botswana Pula')    |
| symbol            | VARCHAR(10)  | NOT NULL                       | Display symbol (e.g., 'P', 'R')      |
| decimal_precision | INTEGER      | DEFAULT 2                      | Decimal places (2 for most currencies) |
| is_active         | BOOLEAN      | DEFAULT TRUE                   | Whether this currency is available    |
| created_at        | TIMESTAMPTZ  | DEFAULT NOW()                  |                                      |

**Seed data:**

| code | name            | symbol | decimal_precision |
|------|-----------------|--------|-------------------|
| BWP  | Botswana Pula   | P      | 2                 |
| ZAR  | South African Rand | R   | 2                 |

**Notes:**
- BWP is the default and only active currency at launch
- ZAR added as seed data (inactive) for when South Africa expansion happens
- Add more currencies as the platform expands to other markets (KES, USD, etc.)

---

### 26. COUNTRIES

Countries the platform operates in. Links stores and farmers to a country and default currency.

| Column            | Type         | Constraints                    | Description                          |
|-------------------|--------------|--------------------------------|--------------------------------------|
| id                | UUID         | PK, DEFAULT uuid_generate_v4() |                                     |
| code              | VARCHAR(2)   | NOT NULL, UNIQUE               | ISO 3166-1 alpha-2 (e.g., 'BW', 'ZA') |
| name              | VARCHAR(100) | NOT NULL                       | Full name (e.g., 'Botswana')         |
| currency_id       | UUID         | FK → currencies.id, NOT NULL   | Default currency for this country    |
| is_active         | BOOLEAN      | DEFAULT TRUE                   | Whether the platform operates here   |
| created_at        | TIMESTAMPTZ  | DEFAULT NOW()                  |                                      |

**Seed data:**

| code | name          | currency |
|------|---------------|----------|
| BW   | Botswana      | BWP      |
| ZA   | South Africa  | ZAR      |

---

## Relationships Diagram

```
profiles
├── 1:1 → farmers (profile_id)
├── 1:1 → stores (profile_id)
├── 1:1 → admin_users (profile_id)
└── 1:N → notifications (recipient_id)

farmers
├── 1:N → farm_images
├── 1:N → farmer_products → N:1 products
├── 1:N → listings
│         └── 1:N → listing_images
├── 1:N → cropping_plans
├── 1:N → tender_offers
├── 1:N → contracts (as farmer)
├── 1:N → orders (as farmer)
├── 1:N → reviews (as reviewed farmer)
└── 1:N → product_requests

stores
├── 1:N → tenders
│         └── 1:N → tender_offers
├── 1:N → contracts (as store)
├── 1:N → orders (as store)
└── 1:N → reviews (as reviewing store)

product_categories
└── 1:N → products
           └── 1:N → product_varieties

contracts
└── 1:N → contract_deliveries

orders
└── 1:N → order_items
└── 1:1 → reviews

currencies
└── 1:N → countries (currency_id)

countries
├── 1:N → farmers (country_id)
└── 1:N → stores (country_id)
```

---

## Indexes (Performance)

Key indexes to create for query performance:

```sql
-- Listings: farmers and stores browse/filter these heavily
CREATE INDEX idx_listings_status ON listings(status);
CREATE INDEX idx_listings_product ON listings(product_id);
CREATE INDEX idx_listings_farmer ON listings(farmer_id);
CREATE INDEX idx_listings_available ON listings(available_from, available_until);

-- Orders: filtered by store, farmer, status
CREATE INDEX idx_orders_store ON orders(store_id);
CREATE INDEX idx_orders_farmer ON orders(farmer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_source ON orders(source);

-- Tenders: stores post, farmers browse
CREATE INDEX idx_tenders_store ON tenders(store_id);
CREATE INDEX idx_tenders_product ON tenders(product_id);
CREATE INDEX idx_tenders_status ON tenders(status);

-- Contracts: both parties query
CREATE INDEX idx_contracts_store ON contracts(store_id);
CREATE INDEX idx_contracts_farmer ON contracts(farmer_id);
CREATE INDEX idx_contracts_status ON contracts(status);

-- Cropping plans: stores browse for forward visibility
CREATE INDEX idx_cropping_plans_farmer ON cropping_plans(farmer_id);
CREATE INDEX idx_cropping_plans_product ON cropping_plans(product_id);
CREATE INDEX idx_cropping_plans_harvest ON cropping_plans(expected_harvest_date);

-- Notifications: user's notification feed
CREATE INDEX idx_notifications_recipient ON notifications(recipient_id);
CREATE INDEX idx_notifications_read ON notifications(recipient_id, is_read);

-- Reviews: aggregate queries for farmer ratings
CREATE INDEX idx_reviews_farmer ON reviews(farmer_id);

-- Farmer products: matching farmers to tenders/contracts
CREATE INDEX idx_farmer_products_farmer ON farmer_products(farmer_id);
CREATE INDEX idx_farmer_products_product ON farmer_products(product_id);
```

---

## Row Level Security (RLS) Policies — Overview

Supabase RLS ensures data isolation between users and roles.

### Profiles
- Users can read and update their own profile
- Admins can read all profiles

### User Roles
- Users can read their own roles
- Admins can read and manage all roles
- Only admins can assign the 'admin' role
- Users cannot modify their own roles (prevents privilege escalation)

### Farmers
- Farmers can read and update their own farmer record
- Stores can read approved farmer profiles (for browsing listings)
- Admins can read and update all farmer records

### Stores
- Stores can read and update their own store record
- Farmers can read active store profiles (to see who's buying)
- Admins can read and update all store records

### Listings
- Farmers can CRUD their own listings
- All stores can read active listings from approved farmers
- Admins can read all listings

### Cropping Plans
- Farmers can CRUD their own cropping plans
- All stores can read cropping plans from approved farmers
- Admins can read all cropping plans

### Tenders
- Stores can CRUD their own tenders
- All approved farmers can read active tenders
- Admins can read all tenders

### Tender Offers
- Farmers can create and read their own offers
- Stores can read offers on their own tenders
- Admins can read all offers

### Contracts
- Stores can create contracts and read their own
- Farmers can read contracts offered to them or that are public
- Admins can read all contracts

### Orders
- Stores can read their own orders
- Farmers can read their own orders
- Admins can read all orders

### Reviews
- Stores can create reviews on their own completed orders
- Farmers can read reviews about themselves
- All stores can read all reviews (public farmer reputation)
- Admins can read all reviews

### Notifications
- Users can only read their own notifications
- Admins can read all notifications

---

## Supabase Storage Buckets

| Bucket           | Purpose                        | Access                 |
|------------------|--------------------------------|------------------------|
| avatars          | User profile photos            | Public read            |
| farm-images      | Farm photos                    | Public read            |
| listing-images   | Produce listing photos         | Public read            |
| store-logos      | Store logo images              | Public read            |
| product-images   | Default product catalogue images | Public read          |

All uploads go through authenticated API calls. Public read means images can be displayed in the app without additional auth.

---

## Database Triggers / Edge Functions

### Auto-Update Triggers

1. **Listing quantity tracking** — When an order is placed against a listing, `quantity_remaining` decreases. When it hits 0, status changes to 'sold'.

2. **Tender fulfillment tracking** — When a tender offer is accepted, `quantity_fulfilled` on the tender increases. When it meets `quantity_needed`, tender status changes to 'fulfilled'.

3. **Contract delivery tracking** — When a contract delivery is confirmed, `total_delivered_qty` on the contract increases and `fulfillment_rate` is recalculated.

4. **Farmer rating aggregation** — When a new review is created, the farmer's `avg_overall_rating`, `avg_quality_rating`, `avg_reliability_rating`, `total_reviews`, and `total_transactions` are recalculated.

5. **Order number generation** — Auto-generate sequential, human-readable order numbers (e.g., ORD-00001, ORD-00002).

6. **Contract delivery scheduling** — When a contract status changes to 'active', auto-generate `contract_deliveries` rows based on `delivery_frequency`, `start_date`, and `end_date`.

7. **Listing expiry** — Periodic job (or on-access check) to mark listings past `available_until` as 'expired'.

8. **Tender expiry** — Mark tenders past `expires_at` as 'expired'.

9. **updated_at timestamps** — Auto-update `updated_at` on any row modification.

---

## Offline-First Strategy (App-Level Pattern)

This is NOT a database table — it's a pattern to implement at the Expo app level for farmers in low-connectivity areas.

### The Problem

Farmers in rural South Africa may have intermittent mobile connectivity. Critical actions like updating a cropping plan, creating a listing, or confirming an order shouldn't be lost if the signal drops.

### The Pattern: Local Action Queue

When the app detects it's offline (using Expo/React Native `NetInfo`), critical actions are saved to the device's local storage (AsyncStorage or MMKV) in a queue format:

```json
{
  "id": "local-uuid",
  "action": "create_listing",
  "payload": {
    "product_id": "...",
    "quantity": 500,
    "unit_id": "...",
    "price_per_unit": 8.00
  },
  "created_at": "2025-02-26T10:00:00Z",
  "synced": false
}
```

When connectivity returns, the app processes the queue in order:
1. Send each queued action to Supabase
2. On success, mark as synced and remove from queue
3. On failure (e.g., conflict — listing stock already sold), notify the farmer

### Which Actions to Queue

| Action | Queue Offline? | Why |
|---|---|---|
| Create / update cropping plan | ✅ Yes | Most likely offline scenario — farmer is on the farm |
| Create listing | ✅ Yes | Farmer may want to list right after harvest |
| Update listing | ✅ Yes | Adjust quantity or price |
| Confirm order (farmer side) | ✅ Yes | Time-sensitive — don't lose confirmations |
| Browse listings / tenders | ❌ No | Requires live data — show cached last-fetch with "offline" indicator |
| Place an order (store side) | ❌ No | Needs real-time stock check — must be online |
| Submit tender offer | ⚠️ Maybe | Could queue, but farmer should see latest tender status |

### Implementation Notes

- Use **MMKV** (fast key-value storage for React Native) or **AsyncStorage** for the queue
- Do NOT use a full offline-first database like WatermelonDB for MVP — too much complexity
- Show a clear "You're offline — changes will sync when connected" indicator in the UI
- Show queued but unsynced items with a visual indicator (e.g., subtle "pending sync" badge)
- When the app comes back online, process the queue silently in the background
- If a queued action conflicts with server state (e.g., listing was already sold out), show the farmer a clear error explaining what happened
- This can be upgraded to a full offline-sync solution (WatermelonDB, PowerSync) in Phase 3 if needed

---

## Relationship Updates (Post User Roles Change)

With the `user_roles` join table, the relationships diagram updates:

```
profiles
├── 1:N → user_roles (profile_id) ← NEW: multi-role support
├── 1:1 → farmers (profile_id)
├── 1:1 → stores (profile_id)
├── 1:1 → admin_users (profile_id)
└── 1:N → notifications (recipient_id)

user_roles
└── N:1 → profiles (profile_id)

farmers
├── 1:N → farm_images
├── 1:N → farmer_products → N:1 products
├── 1:N → listings
│         └── 1:N → listing_images
├── 1:N → cropping_plans
├── 1:N → tender_offers
├── 1:N → contracts (as farmer)
├── 1:N → orders (as farmer)
├── 1:N → reviews (as reviewed farmer)
└── 1:N → product_requests

stores
├── 1:N → tenders
│         └── 1:N → tender_offers
├── 1:N → contracts (as store)
├── 1:N → orders (as store)
└── 1:N → reviews (as reviewing store)

product_categories
└── 1:N → products
           └── 1:N → product_varieties

contracts
└── 1:N → contract_deliveries

orders
└── 1:N → order_items
└── 1:1 → reviews

currencies
└── 1:N → countries (currency_id)

countries
├── 1:N → farmers (country_id)
└── 1:N → stores (country_id)
```

---

## Additional Index (For User Roles)

```sql
-- User roles: checked on every login and role switch
CREATE INDEX idx_user_roles_profile ON user_roles(profile_id);
CREATE INDEX idx_user_roles_active ON user_roles(profile_id, is_active);
```

---

*Document version: 1.2*
*Last updated: February 2025*
*Platform: ReKamoso AgriMart*
*Companion to: REKAMOSO_AGRIMART_PROJECT_BRIEF.md*

*v1.1 Changes: Added user_roles join table (multi-role support), concurrency/race condition handling notes on listings and tenders, offline-first strategy as app-level pattern, updated relationship diagram and indexes.*

*v1.2 Changes: Added currencies and countries tables for multi-country/multi-currency support. Added currency_code column to listings, tenders, tender_offers, contracts, orders, and order_items. Added country_id to farmers and stores. Default currency is BWP (Botswana Pula). ZAR seeded as inactive for future SA expansion.*
