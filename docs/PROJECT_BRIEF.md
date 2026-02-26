# ReKamoso AgriMart — Farmer → Store Platform

## Complete Project Brief & Architecture Document

---

## 1. Project Overview

### What We're Building

ReKamoso AgriMart is a three-sided agricultural marketplace platform that connects horticultural farmers to retail storefronts, and eventually storefronts to end consumers. The platform serves as national agricultural supply infrastructure, enabling farmers to list, sell, and contract their produce to stores efficiently.

### Current Focus

**Phase 1: Farmer → Store Platform Only.** This includes:

- A mobile app (Expo) used by both **farmers** and **store operators** (role-based experience)
- A web-based **admin panel** (Next.js with TypeScript) for platform administrators
- A shared **backend** (Supabase) powering authentication, database, real-time updates, and storage

The consumer-facing storefront and delivery logistics are **Phase 2** and are not in scope for this build.

### Vision

The farmer app is not just a tool for one store — it is designed from day one as a **national agricultural supply network**. Farmers list once and become visible to multiple stores. Each store that joins the platform gains instant access to the farmer network. The architecture is multi-store ready from the start, even though we launch with a single store partner (a Depo).

---

## 2. Platform Users & Roles

### 2.1 Farmers

Horticultural farmers who grow and sell produce. They use the platform to:

- List available produce for stores to purchase (spot market)
- Manage cropping plans showing what they're growing and when it will be ready
- Respond to store procurement requests (tenders)
- Enter into forward agreements with stores (contract farming — lite version)
- Track orders from acceptance through to delivery confirmation
- Build a reputation/reliability score over time through store reviews
- Request new products to be added to the platform catalogue

**Farmer verification is required.** Farmers sign up and submit an application. A platform admin reviews and approves or rejects the application before the farmer can list any produce.

### 2.2 Store Operators

Retail storefronts, depos, restaurants, hotels, or any business that procures fresh produce. They use the platform to:

- Browse available farmer listings and place orders (spot market)
- View upcoming supply from farmer cropping plans (forward visibility)
- Post procurement requests for specific produce needs (tenders)
- Create and manage forward agreements with farmers (contract farming)
- Confirm receipt of deliveries and rate farmer quality/reliability
- Manage their inventory (what they've procured — this feeds into Phase 2 consumer catalogue)

**Currently working with one store partner (a Depo).** The platform is architected for multiple stores from day one. Adding a new store is simply adding a row to the database and onboarding the store operator.

### 2.3 Platform Administrators (Super Admin)

The ReKamoso team managing the platform. Admins use a web-based panel to:

- Approve or reject farmer registration applications
- Manage the product catalogue (approve farmer requests to add new products)
- Manage the units of measure catalogue
- View and oversee all transactions across all stores and farmers
- Manage store accounts
- Monitor platform health, activity, and analytics
- Manage commission rates and platform settings

### 2.4 Third-Party Logistics Partners (Future — Not in Phase 1 Scope for Consumer Delivery)

For the farmer → store flow, delivery is flexible:

- Farmer delivers to the store/depo themselves
- Store collects from the farmer
- Either party requests a third-party logistics partner

This is handled as a **delivery method selection** on each order. Full logistics partner integration with notifications and tracking is Phase 2 scope (consumer delivery).

---

## 3. Core Features — Farmer → Store Platform

### 3.1 Three Procurement Modes

The platform supports three modes of farmer-store interaction, each serving different needs:

#### Mode 1: Spot Market (Immediate Availability)

- Farmer has produce available **now** and lists it on the platform
- Stores browse available listings and place orders
- Short-term, transactional, no forward commitment
- Ideal for surplus, seasonal produce, or new farmers testing the platform

**Flow:**

```
Farmer harvests → lists produce (product, quantity, unit, price, availability window)
    ↓
All registered stores see the listing (filtered by location/relevance)
    ↓
Store places order (specifies quantity needed)
    ↓
Farmer accepts/confirms order
    ↓
Delivery method selected (farmer delivers / store collects / 3PL)
    ↓
Store confirms receipt → rates quality
    ↓
Transaction complete → commission recorded
```

#### Mode 2: Tenders (Store Procurement Requests)

- Store needs specific produce and broadcasts a request to farmers
- Farmers see the tender and respond with offers
- Medium-term, reactive — store is pulling supply rather than farmer pushing it

**Flow:**

```
Store identifies a supply gap
    ↓
Store posts tender: product, quantity needed, date needed by, price range (optional)
    ↓
Eligible farmers receive notification (push + WhatsApp)
    ↓
Farmers submit offers: quantity they can supply, their price, delivery date
    ↓
Store reviews offers → accepts one or more
    ↓
Accepted offers become orders → normal order flow follows
```

#### Mode 3: Contract Farming (Forward Agreements — Lite Version for MVP)

- Store and farmer agree **before planting** on what will be grown, how much, at what price, and when it will be delivered
- Provides guaranteed demand for the farmer and guaranteed supply for the store
- Long-term, planned, relationship-driven — highest value mode

**MVP Contract Farming Features (Lite):**

- Store creates a contract offer: crop type, required quantity, delivery schedule (e.g., weekly), price agreement, contract duration, payment terms
- Contract is published to eligible farmers based on what they grow and their location
- Farmer accepts or declines (no complex negotiation back-and-forth in MVP)
- Once active, the contract links to the farmer's cropping plan (contracted crops are tagged/highlighted)
- Platform tracks deliveries against the contract commitments
- Automated reminders for upcoming contracted deliveries (push + WhatsApp)
- Variance tracking — if farmer delivers less than contracted, the platform flags it
- This tracking feeds into the farmer's reliability score over time

**Deferred to Later Phases:**

- Counter-offers and structured negotiation flows
- Complex dispute resolution workflows
- Penalty structures for contract breaches
- Contract renewal/renegotiation flows

**How the Three Modes Coexist:**

```
        ╱   Spot Market   ╲          ← ad hoc, flexible, low commitment
       ╱───────────────────╲
      ╱      Tenders        ╲       ← medium-term, reactive
     ╱───────────────────────╲
    ╱   Contract Farming      ╲   ← planned, committed, highest value
   ╱───────────────────────────╲
```

New farmers start with spot market listings, build reputation through reviews, and graduate to contracts. Stores use all three modes depending on their needs.

---

### 3.2 Farmer Features (Mobile App)

#### 3.2.1 Registration & Onboarding

- Farmer signs up using phone number + OTP (Supabase Auth)
- Fills in profile: full name, farm name, farm location (GPS or address), farm size, what they grow (select from product categories)
- Upload profile photo and farm photos (optional)
- Application is submitted for **admin approval**
- Farmer receives notification when approved or rejected
- Until approved, farmer can view the platform but cannot list produce or respond to tenders

#### 3.2.2 Product Catalogue (Standardized Dropdown)

- When listing produce, farmers select from a **standardized product dropdown**
- Product catalogue is structured in up to three levels:

```
Category → Subcategory (optional, for future) → Product (with varieties)

Examples:
Vegetables → Tomatoes → Roma, Cherry, Beef, Grape
Fruits → Citrus → Oranges, Lemons, Naartjies, Grapefruit
Herbs → Fresh Herbs → Basil, Coriander, Parsley, Mint
```

- If a product is not in the dropdown, the farmer can submit a **"Request to Add Product"**:
  - Farmer provides: product name, suggested category, description
  - Request goes to platform admin for review
  - Admin approves (product added to catalogue for everyone) or rejects (with reason)
  - Farmer is notified of the outcome

**Starting Categories (Horticulture Focus):**

- Fruits
- Vegetables
- Herbs
- Leafy Greens

**Starting Products (Initial Catalogue — Expandable):**

- **Fruits:** Tomatoes, Apples, Oranges, Bananas, Grapes, Mangoes, Avocados, Peaches, Berries, Watermelon, Lemons
- **Vegetables:** Spinach, Cabbage, Onions, Potatoes, Butternut, Carrots, Green Beans, Peppers, Broccoli, Lettuce, Beetroot
- **Herbs:** Parsley, Coriander, Basil, Mint, Rosemary
- **Leafy Greens:** Kale, Swiss Chard, Rocket, Baby Spinach

Categories and products are stored as database tables and can be added/modified at any time by admins without any code changes or app updates.

#### 3.2.3 Produce Listings (Spot Market)

Farmers create listings for produce they have available now or will have available soon.

**Listing fields:**

- Product (from standardized dropdown)
- Variety (optional — e.g., Roma tomatoes vs Cherry tomatoes)
- Quantity available (numeric value)
- Unit of measure (from standardized dropdown — see Section 4)
- Price per unit (in BWP — Botswana Pula. Platform supports multi-currency for future expansion)
- Quality grade (optional — Grade A, B, C or descriptive)
- Availability window (available from date → available until date)
- Product photos (upload from camera or gallery)
- Description / notes (optional free text — e.g., "organic, no pesticides")
- Delivery options available (farmer delivers / store collects / either)

**Listing states:**

```
Draft → Active → Sold (fully claimed) / Expired (availability window passed)
```

- A listing can be **partially claimed** — if a farmer lists 500kg and a store orders 200kg, the listing updates to show 300kg remaining
- Farmer can edit or deactivate a listing at any time while it's active
- Expired listings are archived, not deleted (data retained for analytics and history)

#### 3.2.4 Cropping Plans

Farmers log what they are currently growing and their expected timelines. This gives stores **forward visibility** into what supply is coming.

**Cropping plan entry fields:**

- Product (from standardized dropdown)
- Variety (optional)
- Date planted
- Expected harvest date
- Estimated yield (quantity + unit)
- Growing status: Planted → Growing → Approaching Harvest → Ready → Harvested
- Contract tag (if this crop is committed to a contract, it's flagged as "Contracted — [Store Name]")
- Notes (optional — e.g., "affected by frost, yield may be lower")

**How cropping plans are used:**

- Stores can browse farmer cropping plans to see what's coming in the next weeks/months
- Contracted crops show up as committed — stores know that supply is reserved
- Uncommitted crops represent potential future spot market listings
- Platform can send automated reminders to farmers as harvest dates approach: "Your tomatoes are expected to be ready in 7 days. Will you be listing them?"

#### 3.2.5 Tenders (Responding to Store Requests)

- Farmer sees a feed of active tenders from stores
- Tenders can be filtered by: product, location, date needed, price range
- Farmer submits an offer on a tender:
  - Quantity they can supply
  - Their price per unit
  - Delivery date they can commit to
  - Delivery method
  - Notes (optional)
- Farmer is notified when their offer is accepted or declined by the store

#### 3.2.6 Contracts (Farmer View)

- Farmer sees incoming contract offers from stores
- Can review contract terms: crop, quantity, delivery schedule, price, duration
- Accept or decline
- Active contracts appear in a "My Contracts" section
- Contracted crops are automatically tagged in the cropping plan
- Farmer receives reminders for upcoming contracted deliveries
- Farmer logs each delivery against the contract (delivered quantity, date, notes)
- Farmer can see their fulfillment rate (e.g., "85% of contracted volume delivered on time")

#### 3.2.7 Order Management

Orders are created when:

- A store purchases from a farmer's spot listing
- A store accepts a farmer's offer on a tender
- A contracted delivery is due

**Order states:**

```
New → Accepted by Farmer → Preparing → Ready for Collection/Delivery → In Transit → Delivered → Confirmed by Store
```

**For each order, the farmer sees:**

- Order number
- Store name
- Products and quantities
- Agreed price
- Delivery method (farmer delivers / store collects / 3PL)
- Expected delivery/collection date
- Current status
- Store's delivery confirmation and quality rating (after completion)

#### 3.2.8 Reviews & Ratings (Farmer Receives)

- After each completed order, the store rates the farmer:
  - Overall rating (1-5 stars)
  - Quality rating (1-5 stars)
  - Reliability rating (did they deliver on time and in full?)
  - Optional written review
- Farmer's profile displays aggregate ratings and review count
- This builds the farmer's **reliability score** which influences their visibility for contracts and tenders
- Farmers cannot review stores in Phase 1 (can be added later)

#### 3.2.9 Notifications (Farmer)

Farmers receive notifications via **push notifications** and **WhatsApp** for:

- Application approved / rejected
- New tender posted matching their products
- New contract offer received
- Order placed on their listing
- Order status changes
- Contracted delivery reminder (upcoming due date)
- Product add request approved / rejected
- Review received from store
- Cropping plan harvest reminder

---

### 3.3 Store Features (Mobile App — Same Expo App, Store Role)

#### 3.3.1 Registration & Onboarding

- Store operator signs up using phone number + OTP
- Fills in store profile: business name, store type (grocery, depo, restaurant, hotel, etc.), location (GPS or address), contact details
- Store is activated by platform admin (or auto-activated in MVP for simplicity)
- Store can have multiple team members (owner + staff) linked to the same store account (future — single login per store for MVP)

#### 3.3.2 Browse Farmer Listings (Spot Market)

- Store sees a feed of all active farmer listings
- Can filter by: product category, specific product, location/distance, price range, quantity, availability date
- Can sort by: nearest, newest, price (low to high / high to low), farmer rating
- Each listing shows: product, variety, quantity available, price per unit, farmer name, farmer rating, location, distance, photos, availability window
- Store taps a listing to view full details and place an order

#### 3.3.3 Place an Order

- Store selects quantity they want from a listing (can be partial — doesn't have to take the full quantity)
- Selects delivery method: farmer delivers / store collects / request 3PL
- Confirms order
- Farmer is notified immediately (push + WhatsApp)
- Order enters the order management flow

#### 3.3.4 View Cropping Plans (Forward Visibility)

- Store can browse cropping plans from all farmers on the platform
- See what's being grown, when it will be ready, and estimated quantities
- Filter by product, expected harvest date, location
- Contracted crops are flagged — store can see what's already committed vs what's potentially available
- This helps the store **plan procurement ahead** rather than only reacting to current listings

#### 3.3.5 Post Tenders (Procurement Requests)

- Store creates a tender when they need specific produce:
  - Product (from catalogue dropdown)
  - Quantity needed
  - Date needed by
  - Price range they're willing to pay (optional — can leave open for farmer offers)
  - Quality requirements (optional)
  - Delivery preference
  - Duration the tender stays open
- Tender is published to all farmers who grow that product
- Farmers are notified (push + WhatsApp)
- Store receives farmer offers and can:
  - Accept one or more offers (partially or fully filling the tender)
  - Decline offers
  - Close the tender when fulfilled
- Accepted offers become orders in the order management flow

#### 3.3.6 Contract Farming (Store View)

- Store creates contract offers:
  - Crop type (from catalogue)
  - Required quantity per delivery
  - Delivery frequency (weekly, biweekly, monthly, custom)
  - Price per unit (fixed for contract duration)
  - Contract start date and end date (or ongoing)
  - Quality standards / requirements
  - Payment terms (on delivery, weekly, monthly)
- Store publishes contract to eligible farmers (filtered by product and location) or sends directly to a specific farmer
- Store sees incoming acceptances from farmers
- Active contracts dashboard shows:
  - All active contracts with farmers
  - Upcoming deliveries and their dates
  - Delivery history and fulfillment rates per farmer
  - Variance alerts (farmer delivered less than contracted)

#### 3.3.7 Order Management (Store View)

The store sees all incoming orders across all procurement modes:

- Orders from spot market purchases
- Orders from accepted tender offers
- Orders from contracted deliveries

**For each order, the store sees:**

- Order number and source (spot / tender / contract)
- Farmer name and rating
- Products, quantities, and prices
- Delivery method and expected date
- Current status

**Store actions:**

- Confirm receipt of delivery
- Record actual quantity received (may differ from ordered — e.g., farmer delivered 180kg instead of 200kg)
- Rate quality and leave a review
- Flag issues (quality problems, short delivery, late delivery)

#### 3.3.8 Delivery Confirmation & Quality Control

When a delivery arrives:

- Store confirms receipt in the app
- Enters actual quantity received per product
- Rates quality (1-5 stars per product)
- Can add photos of received produce
- Can add notes (e.g., "tomatoes slightly overripe, acceptable for today's use")
- If quality is unacceptable, store can flag a partial rejection with reason
- This feeds into the farmer's reliability and quality scores

#### 3.3.9 Inventory View (Basic for Phase 1)

- Store can see a running view of what they've procured:
  - Product, quantity received, date received, farmer source
  - What's coming (from active orders and upcoming contract deliveries)
- This is a basic inventory tracker, not a full inventory management system
- In Phase 2, this inventory feeds directly into the consumer-facing catalogue

#### 3.3.10 Notifications (Store)

Store receives notifications via **push notifications** and **WhatsApp** for:

- New farmer listing matching products they frequently buy
- Farmer offer received on their tender
- Order status updates (farmer accepted, preparing, ready, in transit)
- Contract delivery reminder (upcoming delivery due from farmer)
- Delivery confirmed — prompt to rate
- Contract fulfillment alerts (farmer under-delivered)
- New farmer registered in their area (after admin approval)

---

### 3.4 Admin Panel Features (Next.js Web Application)

#### 3.4.1 Farmer Management

- View all farmer applications (pending, approved, rejected)
- Review farmer profiles and approve or reject registration
- View farmer activity: listings, orders, contracts, ratings
- Suspend or deactivate farmer accounts if needed
- View farmer statistics and performance metrics

#### 3.4.2 Store Management

- View all registered stores
- Activate or deactivate store accounts
- View store activity: orders placed, tenders posted, contracts created
- View store statistics

#### 3.4.3 Product Catalogue Management

- View and manage all product categories
- Add, edit, or deactivate categories
- View and manage all products within categories
- Add, edit, or deactivate products
- Review and approve/reject farmer product add requests (with notification to farmer)
- Manage product varieties

#### 3.4.4 Units of Measure Management

- View and manage all units of measure
- Add, edit, or deactivate units
- Assign units to context (farmer→store bulk units vs future store→consumer retail units)

#### 3.4.5 Transaction Oversight

- View all orders across the platform
- Filter by: store, farmer, product, date range, status, procurement mode (spot/tender/contract)
- View transaction details and associated commission
- View all active contracts and their fulfillment status
- View all active and past tenders

#### 3.4.6 Platform Settings

- Set commission rate (percentage per transaction — field ready, rate to be decided)
- Manage notification templates (push and WhatsApp message formats)
- Platform-wide announcements to farmers and/or stores

#### 3.4.7 Analytics & Reporting (Basic for MVP)

- Total farmers, stores, listings, orders, contracts
- Transaction volume and value over time
- Most traded products
- Active vs inactive farmers
- Commission revenue tracking
- Geographic distribution of farmers and stores

---

## 4. Units of Measure

Units are standardized and stored as a database table. New units can be added by admins at any time.

### Farmer → Store (Bulk / Wholesale)

| Unit   | Abbreviation | Use Case                          |
|--------|-------------|-----------------------------------|
| Kilogram | kg        | Most common — vegetables, fruit   |
| Tonne  | t           | Large scale — potatoes, onions    |
| Crate  | crate       | Standard farm crates              |
| Bunch  | bunch       | Herbs, leafy greens, bananas      |
| Bag    | bag         | Potatoes, onions, carrots in bags |
| Each   | each        | Watermelons, pumpkins, cabbage heads |

### Store → Consumer (Retail — Phase 2)

| Unit   | Abbreviation | Use Case                           |
|--------|-------------|------------------------------------|
| Kilogram | kg        | Loose produce by weight            |
| Gram   | g           | Herbs, small quantities            |
| Each   | each        | Avocados, lemons, single items     |
| Pack   | pack        | Pre-packed portions                |
| Bunch  | bunch       | Herbs, spring onions               |

The store handles the conversion between bulk procurement units and retail units when managing their consumer catalogue (Phase 2). For example, a farmer sells a 10kg crate of tomatoes to the store, and the store lists tomatoes at P25/kg to consumers.

---

## 5. Data Flow — Farmer → Store

### Complete Transaction Flow

```
PLANNING PHASE:
├── Farmer registers → admin approves
├── Farmer sets up profile and selects products they grow
├── Farmer logs cropping plan (what's planted, expected harvest dates, estimated yields)
├── Store registers and is activated
├── Store reviews farmer cropping plans for forward visibility
├── Store creates contracts with farmers for planned supply
└── Contracted crops are tagged in farmer cropping plans

LISTING PHASE:
├── Farmer harvests produce
├── Farmer creates listing (product, quantity, unit, price, photos, availability window)
├── All stores receive notification of new listing (if matching their interests)
├── OR: store posts a tender for produce they need
├── Farmers receive tender notification and submit offers
└── Listings and tender responses feed the spot market

ORDER PHASE:
├── Store purchases from farmer listing (spot market)
├── OR: Store accepts farmer's tender offer
├── OR: Contract delivery comes due
├── Order is created with details and delivery method
├── Farmer accepts and prepares order
├── Delivery method is executed (farmer delivers / store collects / 3PL)
└── Farmer marks order as dispatched/ready

COMPLETION PHASE:
├── Store confirms receipt of delivery
├── Store records actual quantity received
├── Store rates quality and leaves review
├── Transaction is complete
├── Commission is recorded
├── Farmer's reliability score updates
└── Procured produce enters store inventory
```

### Notification Flow

```
FARMER NOTIFICATIONS (Push + WhatsApp):
├── Application status (approved/rejected)
├── New tender matching their products
├── Contract offer received
├── Order placed on their listing
├── Order status changes
├── Contracted delivery reminders
├── Product add request outcome
├── Review received
└── Harvest reminders from cropping plan

STORE NOTIFICATIONS (Push + WhatsApp):
├── New farmer listing matching their interests
├── Offer received on their tender
├── Order status updates
├── Contract delivery reminders
├── Delivery confirmation prompts
├── Contract fulfillment alerts
└── New farmer in their area
```

---

## 6. Multi-Store Architecture

### Design Principle

Every piece of data in the system that relates to a store has a `store_id` foreign key. This means:

- Orders belong to a `store_id` + `farmer_id`
- Contracts belong to a `store_id` + `farmer_id`
- Tenders are posted by a `store_id`
- Reviews are linked to a `store_id` + `farmer_id`
- Inventory records belong to a `store_id`

When there is one store, all records share the same `store_id`. When a new store joins, their records use a different `store_id`. No code changes are required — the data layer supports multiple stores from day one.

### What Farmers See

- Farmer listings are visible to **all stores** by default (open marketplace)
- Location-based relevance: stores see nearby farmers first, but can browse nationally
- Contracted produce is **reserved** for the contracted store and not visible to others as available supply
- A farmer can have contracts with **multiple different stores** for different crops

### What Each Store Sees

- All active farmer listings (filtered by their preferences and location)
- Only their own orders, contracts, and tenders
- Only their own inventory and transaction history
- They do not see other stores' orders, contracts, or commercial activity

### Future Considerations (Not MVP)

- Stores could set preferred farmer lists
- Exclusive relationships (a farmer only supplies one store for a specific product)
- Regional farmer pools
- Store-to-store transfers or referrals

---

## 7. Review & Rating System

### Store Reviews Farmer (Phase 1)

After every completed order, the store is prompted to rate the farmer:

- **Overall rating:** 1-5 stars
- **Quality rating:** 1-5 stars (produce quality)
- **Reliability rating:** 1-5 stars (on-time, correct quantities)
- **Written review:** optional free text

These ratings aggregate into the farmer's public profile:

- Average overall rating
- Average quality rating
- Average reliability rating
- Total number of completed transactions
- Total review count
- Contract fulfillment rate (percentage of contracted volume delivered on time)

### How Ratings Are Used

- Displayed on farmer profiles visible to all stores
- Higher-rated farmers appear more prominently in search/browse
- Stores can filter farmers by minimum rating
- Farmer reliability score influences contract eligibility (stores can see track record before offering contracts)

### Farmer Reviews Store (Not in Phase 1)

In a future phase, farmers could rate stores on:

- Payment reliability (paid on time)
- Communication
- Fairness in quality assessments

This creates a **two-sided trust system** that benefits both parties.

---

## 8. Revenue Model

### Commission Per Transaction

- A commission percentage is charged on each completed transaction (farmer → store)
- The commission rate is configurable by the platform admin and stored in platform settings
- The exact percentage is **to be decided** — the database has a field ready for it
- Commission is calculated on the total order value (quantity × price per unit)
- Commission tracking is built into the platform from day one, even if not actively charged initially

### Future Revenue Streams (Not MVP)

- **Value-Added Services (VAS):** Input supply marketplace (seeds, fertilizer), crop insurance, farmer financing against contracts, premium analytics for stores, featured listings for farmers
- **Subscription tiers:** Premium store accounts with advanced features
- **Data monetization:** Aggregated (anonymized) agricultural supply data and market intelligence

---

## 9. Technical Architecture

### Tech Stack

| Layer                 | Technology               | Purpose                                          |
|-----------------------|--------------------------|--------------------------------------------------|
| Mobile App            | Expo (React Native)      | Single codebase → iOS, Android, and Web          |
| Admin Panel           | Next.js with TypeScript  | Web-based admin dashboard                        |
| Backend / Database    | Supabase                 | PostgreSQL database, authentication, real-time subscriptions, file storage |
| Authentication        | Supabase Auth            | Phone number + OTP for farmers and stores        |
| Push Notifications    | Expo Notifications       | Mobile push notifications                        |
| WhatsApp Notifications| Twilio or Meta WhatsApp Business API | WhatsApp message notifications to farmers and stores |
| Hosting (Web/Admin)   | Vercel                   | Next.js hosting for admin panel                  |
| File Storage          | Supabase Storage         | Produce photos, farm photos, profile images      |
| Language              | TypeScript throughout    | Type safety across all codebases                 |

### App Architecture

```
Expo App (Single Codebase)
├── Farmer Experience (role: farmer)
│   ├── Dashboard / Home
│   ├── My Cropping Plan
│   ├── My Listings (create, edit, manage)
│   ├── Marketplace (tenders from stores)
│   ├── My Contracts
│   ├── My Orders
│   ├── Notifications
│   └── Profile / Farm Info
│
├── Store Experience (role: store)
│   ├── Dashboard / Home
│   ├── Browse Farmer Listings
│   ├── Cropping Plans (forward visibility)
│   ├── My Tenders (create, manage)
│   ├── My Contracts (create, manage)
│   ├── My Orders
│   ├── Inventory (basic)
│   ├── Notifications
│   └── Store Profile
│
└── Shared Components
    ├── Authentication (phone + OTP)
    ├── Product catalogue selector
    ├── Order cards and status tracking
    ├── Notification handler
    ├── Image upload
    └── Rating / review components

Next.js Admin Panel (Separate Codebase)
├── Farmer Management (applications, approvals, profiles)
├── Store Management (accounts, activity)
├── Product Catalogue Management (categories, products, requests)
├── Units of Measure Management
├── Transaction Oversight (orders, contracts, tenders)
├── Platform Settings (commission rate, notifications)
└── Analytics & Reporting (basic)

Supabase Backend (Shared)
├── PostgreSQL Database
├── Auth (phone OTP)
├── Real-time Subscriptions (live updates for listings, orders)
├── Storage (images)
├── Edge Functions (business logic, notifications)
└── Row Level Security (farmers see their data, stores see theirs, admins see all)
```

### Platform Support

The Expo app runs on:

- **iOS** — native mobile app (App Store)
- **Android** — native mobile app (Google Play Store)
- **Web** — same Expo codebase renders in browser (farmers and stores can access from laptops/computers)

The admin panel runs on:

- **Web only** (Next.js) — accessed by platform administrators via browser

### Multi-Store Data Isolation

- **Row Level Security (RLS)** in Supabase ensures each store only sees their own orders, contracts, tenders, and inventory
- Farmer listings are visible to all stores (public marketplace)
- Admin role bypasses RLS to see everything
- Every relevant table includes a `store_id` column for data partitioning

---

## 10. Farmer Verification Flow

### Registration Process

```
Farmer downloads app → signs up with phone + OTP
    ↓
Fills in registration form:
- Personal details (name, ID number or business registration)
- Farm details (name, location, size, type)
- What they grow (select product categories)
- Farm photos (optional but encouraged)
    ↓
Application submitted → status: PENDING
    ↓
Admin receives notification of new application
    ↓
Admin reviews in admin panel:
- Verify information
- Check for duplicates
- Approve or reject (with reason if rejected)
    ↓
Farmer receives notification:
- APPROVED → full access, can list produce, respond to tenders, accept contracts
- REJECTED → shown reason, can reapply with updated information
```

### Account States

```
PENDING    → just registered, awaiting admin review (can browse but not list or transact)
APPROVED   → fully active, all features available
REJECTED   → cannot transact, shown rejection reason, can reapply
SUSPENDED  → previously active but suspended by admin (e.g., repeated quality issues)
```

---

## 11. Delivery Model (Farmer → Store)

For the farmer-to-store flow, delivery is flexible and determined per order:

### Option A: Farmer Delivers

- Farmer transports produce to the store's depo/location
- Farmer selects this option when confirming an order
- Delivery cost is the farmer's responsibility (factored into their pricing)

### Option B: Store Collects

- Store arranges their own transport to collect from the farmer
- Store selects this option when placing an order
- Collection cost is the store's responsibility

### Option C: Third-Party Logistics (3PL)

- Either party can request a logistics partner
- Logistics partner receives a pickup notification with:
  - Pickup location (farmer)
  - Drop-off location (store)
  - Products and quantities
  - Required pickup/delivery date
- Logistics cost is assigned to the requesting party (or split — to be determined)
- Full 3PL integration with tracking is Phase 2. For MVP, this may be a manual notification (e.g., WhatsApp to logistics partner) with basic status tracking

### Delivery Status Tracking

Regardless of delivery method, the order tracks:

```
Order Confirmed → Preparing → Ready for Pickup/Dispatch → In Transit → Delivered → Confirmed by Store
```

---

## 12. Payment Model (Phase 1)

### Cash / EFT

- All payments between stores and farmers happen **outside the platform** in Phase 1
- Cash on delivery or EFT bank transfer
- The platform **records the transaction value** for commission tracking and reporting
- The store marks an order as "paid" and the farmer confirms receipt of payment

### Commission Tracking

- Even though payment flows externally, the platform calculates and records commission on each completed transaction
- Commission amount = order value × commission rate (set by admin)
- Commission collection method is outside the platform for now (invoiced separately)

### Future Payment Integration (Phase 2+)

- Integrate a payment gateway for in-platform payments
- Automated commission deduction before farmer payout
- Payment history and statements for farmers and stores
- Integration with mobile money or instant EFT services

---

## 13. Phase Overview & Roadmap

### Phase 1: Farmer → Store Platform (Current Build)

**Delivering:**

- Expo mobile app (farmer + store roles) with web access
- Next.js admin panel
- Supabase backend
- Farmer registration with admin verification
- Standardized product catalogue with request-to-add
- Produce listings (spot market)
- Cropping plans
- Tenders (store procurement requests)
- Contract farming (lite version)
- Order management with delivery method selection
- Store review/rating of farmers
- Push + WhatsApp notifications
- Commission tracking (rate TBD)
- Multi-store ready architecture

### Phase 2: Store → Consumer Platform (Future)

**Will deliver:**

- Consumer mobile app (Expo — could be same codebase with consumer role, or separate)
- Consumer-facing store catalogue (browse, search, product details)
- Cart and checkout flow
- Cash on delivery and/or EFT payment
- Third-party logistics partner integration (Uber Eats-style delivery)
- Delivery tracking for consumers
- Consumer reviews of store
- Store catalogue management (retail pricing with markup from procurement cost)
- Inventory connection (procured stock feeds consumer catalogue availability)

### Phase 3: Growth & Scale

**Will deliver:**

- Multi-store consumer experience (consumer sees multiple stores, picks one — like Uber Eats)
- White-label / branded storefronts per store (optional)
- In-platform payment gateway
- Full logistics partner management with real-time tracking
- Contract farming advanced features (negotiation, disputes, penalties)
- Farmer input marketplace (seeds, fertilizer, equipment)
- Farmer financing against contracts
- Crop insurance partnerships
- Advanced analytics and market intelligence
- SMS notifications for farmers without smartphones
- Multi-language support

---

## 14. Key Design Decisions Summary

| Decision                      | Choice                                                          |
|-------------------------------|-----------------------------------------------------------------|
| Platform separation           | Two flows (farmer→store, store→consumer), one mobile codebase   |
| Mobile framework              | Expo (React Native) — iOS, Android, Web from one codebase      |
| Admin panel                   | Next.js with TypeScript (web only)                              |
| Backend                       | Supabase (PostgreSQL, auth, real-time, storage)                 |
| Language                      | TypeScript throughout                                           |
| Authentication                | Phone number + OTP via Supabase Auth                            |
| Farmer verification           | Admin approval required before farmer can transact              |
| Product catalogue             | Standardized dropdown + request to add (admin approves)         |
| Units of measure              | Standardized per context, stored as database table              |
| Multi-store                   | Architected from day one, launching with one store              |
| Procurement modes             | Spot market + tenders + contract farming (lite)                 |
| Delivery (farmer→store)       | Flexible per order: farmer delivers / store collects / 3PL      |
| Payment (Phase 1)             | Cash / EFT outside platform, transactions recorded in platform  |
| Revenue model                 | Commission per transaction (rate TBD), future pivot to VAS      |
| Notifications                 | Push notifications (Expo) + WhatsApp (Twilio/Meta API)          |
| Quality control               | Store reviews/rates farmer after each delivery                  |
| Farmer inputs marketplace     | Later phase, not in scope                                       |
| Consumer app                  | Phase 2                                                         |
| Logistics integration         | Phase 2 (3PL for consumer delivery)                             |
| Development tools             | Cursor initially, transitioning to Claude Code                  |

---

## 15. Open Items (To Be Decided Later)

- Commission rate percentage
- Exact 3PL logistics partner and integration method
- Payment gateway selection for Phase 2
- Consumer app as same codebase (new role) vs separate Expo project
- Branding and visual design direction (colors, fonts, imagery)
- WhatsApp notification provider (Twilio vs Meta direct)
- Farmer input marketplace scope and partners
- Contract farming advanced features (negotiation, dispute resolution, penalties)

---

*Document version: 1.0*
*Last updated: February 2025*
*Platform: ReKamoso AgriMart*
*Focus: Phase 1 — Farmer → Store*
