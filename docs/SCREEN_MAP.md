# ReKamoso AgriMart — Screen Map

## Farmer → Store Platform (Phase 1)

---

## Overview

This document maps every screen in the platform, what data it reads, what data it writes, what actions the user can take, and where each screen navigates to. This is the blueprint for building each screen.

### Screen Count Summary

| App | Screens |
|---|---|
| Auth Flow | 6 |
| Farmer Experience | 16 |
| Store Experience | 19 |
| Shared | 2 |
| Admin Panel | 16 |
| **Total** | **59** |

---

## 1. AUTH FLOW

Screens visible to unauthenticated users. No bottom tabs.

---

### 1.1 Welcome Screen

**Route:** `(auth)/welcome.tsx`

**Purpose:** Landing screen. First thing a new user sees.

**UI Elements:**
- App logo and branding
- Tagline: "Connecting Farmers to Storefronts"
- "Get Started" button → Register
- "I already have an account" link → Login
- Background image or illustration (agricultural theme)

**Data Read:** None
**Data Write:** None
**Navigation:**
- "Get Started" → Register
- "I already have an account" → Login

---

### 1.2 Login Screen

**Route:** `(auth)/login.tsx`

**Purpose:** Existing user enters phone number to receive OTP.

**UI Elements:**
- Phone number input (with country code selector — default +267 Botswana)
- "Send OTP" button
- "Don't have an account?" link → Register
- Loading state while OTP is being sent

**Data Read:** None
**Data Write:**
- Triggers Supabase Auth OTP send to phone number

**Validation:**
- Phone number required, valid format
- Country code required

**Navigation:**
- "Send OTP" success → Verify OTP (pass phone number)
- "Don't have an account?" → Register

---

### 1.3 Verify OTP Screen

**Route:** `(auth)/verify-otp.tsx`

**Purpose:** User enters the OTP received via SMS.

**UI Elements:**
- Display: "Code sent to +267 XX XXX XXXX"
- 6-digit OTP input (auto-focus, auto-advance between digits)
- "Verify" button
- "Resend code" link (with countdown timer — e.g., 60 seconds)
- Loading state during verification

**Data Read:**
- Phone number (passed from login screen)

**Data Write:**
- Supabase Auth verify OTP → creates session

**Validation:**
- 6-digit code required

**Navigation:**
- Verification success + existing user with roles → Role-based routing (farmer/store home)
- Verification success + existing user with farmer role pending → Pending Approval screen
- Verification success + new user (no profile) → Register
- "Resend code" → re-triggers OTP, resets timer

---

### 1.4 Register — Role Selection

**Route:** `(auth)/register.tsx`

**Purpose:** New user selects their role. Shown after OTP verification for users without a profile.

**UI Elements:**
- "What best describes you?" heading
- Two large cards/buttons:
  - 🌱 "I'm a Farmer" — "I grow and sell produce"
  - 🏪 "I'm a Store" — "I buy produce to sell to customers"
- Each card has an icon, title, and short description

**Data Read:**
- Auth session (user is authenticated but has no profile yet)

**Data Write:** None (role selection is passed to next screen)

**Navigation:**
- "I'm a Farmer" → Register Farmer
- "I'm a Store" → Register Store

---

### 1.5 Register Farmer

**Route:** `(auth)/register-farmer.tsx`

**Purpose:** Farmer fills in their profile and farm details. Multi-step form.

**UI Elements — Step 1 (Personal Info):**
- Full name input
- Email input (optional)
- ID number / business registration (optional)
- Profile photo upload (camera or gallery)

**UI Elements — Step 2 (Farm Details):**
- Farm name input
- Farm location (GPS auto-detect button + manual address input)
- Country selector (default: Botswana)
- Farm size input + unit selector (hectares / acres / sqm)
- Farm photos upload (multiple, optional)

**UI Elements — Step 3 (What You Grow):**
- Multi-select from product categories and products
- "Select the products you grow" — checkboxes or chip selectors
- Categories expandable to show products within

**UI Elements — Step 4 (Review & Submit):**
- Summary of all entered information
- "Submit Application" button
- Note: "Your application will be reviewed by our team. You'll be notified when approved."

**Data Read:**
- Product categories and products (from `product_categories` + `products` tables)
- Countries (from `countries` table)

**Data Write:**
- Creates `profiles` row (full_name, phone, email, avatar_url)
- Creates `user_roles` row (profile_id, role: 'farmer')
- Creates `farmers` row (farm_name, location, country_id, farm_size, verification_status: 'pending')
- Creates `farm_images` rows (if photos uploaded)
- Creates `farmer_products` rows (selected products)

**Validation:**
- Full name required
- Farm name required
- At least one product selected
- Location recommended but not required

**Navigation:**
- "Submit Application" → Pending Approval Screen

---

### 1.6 Register Store

**Route:** `(auth)/register-store.tsx`

**Purpose:** Store operator fills in their business details.

**UI Elements:**
- Business name input
- Store type selector (grocery, depo, restaurant, hotel, other)
- Location (GPS auto-detect + manual address)
- Country selector (default: Botswana)
- Contact phone (pre-filled from auth, editable)
- Contact email (optional)
- Business description / bio (optional)
- Store logo upload (optional)

**Data Read:**
- Countries (from `countries` table)

**Data Write:**
- Creates `profiles` row
- Creates `user_roles` row (profile_id, role: 'store')
- Creates `stores` row (business_name, store_type, location, country_id)

**Validation:**
- Business name required
- Store type required

**Navigation:**
- Submit → Store Home (stores are auto-activated for MVP, or pending if admin approval is required)

---

## 2. FARMER EXPERIENCE

Screens visible to authenticated users with active farmer role and `verification_status = 'approved'`. Bottom tab navigation.

**Tab Bar:** Home | Listings | Marketplace | Orders | Profile

---

### 2.1 Farmer Home / Dashboard

**Route:** `(farmer)/(tabs)/home.tsx`

**Tab:** Home

**Purpose:** At-a-glance overview of the farmer's activity.

**UI Elements:**
- Welcome message: "Good morning, [name]"
- Role switcher button (if user has multiple roles — top right)
- **Quick Stats Cards:**
  - Active listings count
  - Open orders count
  - Active contracts count
  - Average rating (stars)
- **Upcoming Section:**
  - Next harvest due (from cropping plans closest to harvest date)
  - Next contract delivery due (from contract_deliveries)
- **Recent Activity Feed:**
  - Last 5 notifications (new orders, tender matches, reviews)
  - Each item tappable → navigates to relevant screen
- **Quick Actions:**
  - "+ New Listing" button
  - "View Tenders" button
- Notification bell icon (top right) with unread count badge

**Data Read:**
- `farmers` — current farmer profile (ratings, verification)
- `listings` — count where farmer_id = me AND status = 'active'
- `orders` — count where farmer_id = me AND status IN ('new', 'accepted', 'preparing', 'ready', 'in_transit')
- `contracts` — count where farmer_id = me AND status = 'active'
- `cropping_plans` — next approaching harvest (ORDER BY expected_harvest_date ASC, LIMIT 1 where status != 'harvested')
- `contract_deliveries` — next upcoming delivery (ORDER BY expected_date ASC, LIMIT 1 where status = 'upcoming')
- `notifications` — last 5, ordered by created_at DESC
- `notifications` — count where is_read = false (for badge)

**Data Write:** None (read-only dashboard)

**Real-time Subscriptions:**
- `notifications` — new notifications update badge count and feed
- `orders` — new order placed on farmer's listing triggers refresh

**Navigation:**
- Stats cards → respective list screens
- Notification items → relevant detail screens
- "+ New Listing" → Create Listing
- "View Tenders" → Marketplace / Tenders
- Notification bell → Notifications screen

---

### 2.2 My Listings — List View

**Route:** `(farmer)/(tabs)/listings/index.tsx`

**Tab:** Listings

**Purpose:** View all farmer's produce listings.

**UI Elements:**
- Tab filters at top: All | Active | Draft | Sold | Expired
- List of ListingCards, each showing:
  - Product name + variety
  - Quantity remaining / total quantity + unit
  - Price per unit (with currency symbol)
  - Status badge
  - Availability window dates
  - Thumbnail image
- Empty state: "No listings yet. Create your first listing!"
- Floating action button: "+ New Listing"
- Pull-to-refresh

**Data Read:**
- `listings` — WHERE farmer_id = me, with joined product name, variety name, unit abbreviation
- `listing_images` — first image for each listing (thumbnail)

**Data Write:** None

**Navigation:**
- Tap listing → Listing Detail [id]
- "+ New Listing" → Create Listing
- Tab filters → re-query with status filter

---

### 2.3 Create Listing

**Route:** `(farmer)/(tabs)/listings/create.tsx`

**Tab:** Listings

**Purpose:** Farmer creates a new produce listing.

**UI Elements:**
- Product picker (dropdown from standardized catalogue)
- Variety picker (optional — populates based on selected product)
- "Product not listed?" link → Product Request Modal
- Title input (optional — auto-generates from product + variety if empty)
- Description / notes textarea (optional)
- Quantity input + unit picker (dropdown: kg, tonne, crate, bunch, bag, each)
- Price per unit input (with currency symbol — auto BWP)
- Quality grade selector (optional: A, B, C, or free text)
- Available from date picker
- Available until date picker
- Delivery options selector (I deliver / Store collects / Either)
- Photo upload (multiple — camera or gallery, max 5)
- "Save as Draft" button
- "Publish Listing" button

**Data Read:**
- `products` — for product picker (joined with categories)
- `product_varieties` — filtered by selected product
- `units_of_measure` — WHERE context IN ('farmer_to_store', 'both')
- `currencies` — for current user's country currency
- `farmers` — current farmer's country_id to determine currency

**Data Write:**
- Creates `listings` row (status: 'draft' or 'active')
- Creates `listing_images` rows (uploaded photos)
- Sets `quantity_remaining` = `quantity`
- Sets `currency_code` based on farmer's country

**Offline Queue:** ✅ Yes — if offline, queue the create action

**Validation:**
- Product required
- Quantity required, > 0
- Unit required
- Price required, > 0
- Available from required
- Available until required, must be after available_from
- At least one photo recommended (not required)

**Navigation:**
- "Save as Draft" → Listings list (with success toast)
- "Publish Listing" → Listings list (with success toast, notifications sent to stores)
- Product Request Modal → submits request, returns to form

---

### 2.4 Listing Detail

**Route:** `(farmer)/(tabs)/listings/[id].tsx`

**Tab:** Listings

**Purpose:** View full listing details. Edit or manage the listing.

**UI Elements:**
- Image carousel (listing photos)
- Product name, variety, quality grade
- Price per unit with currency
- Quantity: remaining / total (with progress bar)
- Unit of measure
- Availability window
- Delivery options
- Description / notes
- Status badge
- **Actions (based on status):**
  - Active: "Edit Listing", "Deactivate"
  - Draft: "Edit Listing", "Publish", "Delete"
  - Sold/Expired: "Relist" (create new listing pre-filled with same data)
- Orders section: list of orders placed against this listing (if any)

**Data Read:**
- `listings` — single listing WHERE id = [id] AND farmer_id = me
- `listing_images` — all images for this listing
- `products` + `product_varieties` + `units_of_measure` — joined names
- `orders` — WHERE listing_id = [id] (orders against this listing)

**Data Write:**
- Status updates (deactivate, publish, delete)
- Edit fields (quantity, price, dates, etc.)

**Navigation:**
- "Edit Listing" → Create/Edit form (pre-filled)
- Order items → Order Detail
- "Relist" → Create Listing (pre-filled)

---

### 2.5 Cropping Plans — List View

**Route:** `(farmer)/(tabs)/cropping-plans/index.tsx`

**Tab:** Home (accessible from dashboard) or could be a sub-tab

**Purpose:** View all cropping plan entries as a timeline or list.

**UI Elements:**
- Toggle: List View | Timeline View
- **List View:** CroppingPlanCards ordered by expected_harvest_date, each showing:
  - Product name + variety
  - Date planted → Expected harvest date
  - Estimated yield + unit
  - Growing status badge (planted, growing, approaching harvest, ready, harvested)
  - Contract tag if committed (🔒 "Contracted — [Store Name]")
- **Timeline View:** Visual timeline with crop bars showing planting → harvest periods
- Filter by: growing status, product
- "+ Add Crop" button
- Pull-to-refresh

**Data Read:**
- `cropping_plans` — WHERE farmer_id = me, joined with product, variety, unit names
- `contracts` — joined for contracted plans (to show store name)

**Data Write:** None

**Navigation:**
- Tap plan → Cropping Plan Detail [id]
- "+ Add Crop" → Create Cropping Plan

---

### 2.6 Create / Edit Cropping Plan

**Route:** `(farmer)/(tabs)/cropping-plans/create.tsx`

**Purpose:** Add a new cropping plan entry.

**UI Elements:**
- Product picker (from catalogue)
- Variety picker (optional)
- Date planted (date picker)
- Expected harvest date (date picker)
- Estimated yield input + unit picker
- Growing status selector (default: 'planted')
- Notes textarea (optional)
- "Save" button

**Data Read:**
- `products`, `product_varieties`, `units_of_measure`

**Data Write:**
- Creates or updates `cropping_plans` row

**Offline Queue:** ✅ Yes

**Validation:**
- Product required
- Date planted required
- Expected harvest date required, must be after date planted
- Estimated yield recommended

**Navigation:**
- "Save" → Cropping Plans list (success toast)

---

### 2.7 Cropping Plan Detail

**Route:** `(farmer)/(tabs)/cropping-plans/[id].tsx`

**Purpose:** View and update a single cropping plan entry.

**UI Elements:**
- Full detail view: product, variety, dates, yield, status, notes
- Contract tag if committed
- **Status update buttons:** "Mark as Growing", "Approaching Harvest", "Ready to Harvest", "Harvested"
- Actual yield input (appears when status is set to 'harvested')
- "Edit" button
- "Create Listing from Crop" button (pre-fills a new listing from this plan's data)

**Data Read:**
- `cropping_plans` — single plan WHERE id = [id]
- `contracts` — if plan is contracted

**Data Write:**
- Update `growing_status`
- Update `actual_yield` when harvested

**Offline Queue:** ✅ Yes (status updates)

**Navigation:**
- "Edit" → Edit form
- "Create Listing from Crop" → Create Listing (pre-filled: product, variety, yield as quantity)

---

### 2.8 Marketplace — Hub

**Route:** `(farmer)/(tabs)/marketplace/index.tsx`

**Tab:** Marketplace

**Purpose:** Combined view of tenders and contracts for the farmer.

**UI Elements:**
- Two sub-tabs: **Tenders** | **My Contracts**
- Tenders sub-tab shows active tenders (see 2.9)
- My Contracts sub-tab shows farmer's contracts (see 2.11)
- Notification badge on each sub-tab if new items

**Data Read:** Delegated to sub-screens

**Navigation:**
- Sub-tabs switch between tenders and contracts views

---

### 2.9 Browse Tenders

**Route:** `(farmer)/(tabs)/marketplace/tenders/index.tsx`

**Purpose:** Browse active tenders from stores.

**UI Elements:**
- Filter bar: Product, Location/Distance, Date needed by
- Sort: Newest, Nearest, Highest price
- List of TenderCards, each showing:
  - Product needed + quantity + unit
  - Price range (if specified) with currency
  - Date needed by
  - Store name + location
  - Time remaining (if expires_at set)
  - "Already offered" badge (if farmer has submitted an offer)
- Empty state: "No tenders matching your products right now."
- Pull-to-refresh

**Data Read:**
- `tenders` — WHERE status = 'active', joined with product, unit, store names
- `tender_offers` — WHERE farmer_id = me (to show "already offered" badge)
- `farmer_products` — to highlight tenders matching farmer's products

**Data Write:** None

**Real-time:** Subscribe to new tenders matching farmer's products

**Navigation:**
- Tap tender → Tender Detail [id]

---

### 2.10 Tender Detail + Submit Offer

**Route:** `(farmer)/(tabs)/marketplace/tenders/[id].tsx`

**Purpose:** View tender details and submit an offer.

**UI Elements:**
- **Tender Details:**
  - Product name + variety (if specified)
  - Quantity needed + unit
  - Price range (if specified) with currency
  - Date needed by
  - Quality requirements
  - Delivery preference
  - Store name, location, rating (if applicable)
  - Time remaining
- **Submit Offer Section (if not already offered):**
  - Quantity I can supply (input + unit — auto-matched to tender unit)
  - My price per unit (input with currency)
  - Delivery date I can commit to (date picker)
  - Delivery method selector
  - Notes (optional)
  - "Submit Offer" button
- **My Offer Section (if already offered):**
  - Show submitted offer details
  - Offer status badge (pending, accepted, declined)
  - "Withdraw Offer" button (if still pending)

**Data Read:**
- `tenders` — single tender WHERE id = [id]
- `tender_offers` — WHERE tender_id = [id] AND farmer_id = me (check if already offered)
- `stores` — store profile for display

**Data Write:**
- Creates `tender_offers` row (on submit)
- Deletes `tender_offers` row (on withdraw)

**Validation:**
- Quantity required, > 0
- Price required, > 0
- Delivery date required

**Navigation:**
- "Submit Offer" → success toast, back to tenders list
- "Withdraw Offer" → confirmation modal → success toast

---

### 2.11 My Contracts

**Route:** `(farmer)/(tabs)/marketplace/contracts/index.tsx`

**Purpose:** View all contracts the farmer is part of.

**UI Elements:**
- Tab filters: Active | Upcoming | Completed | All
- List of ContractCards, each showing:
  - Product name + variety
  - Store name
  - Quantity per delivery + unit
  - Price per unit with currency
  - Delivery frequency
  - Contract period (start → end)
  - Fulfillment rate (progress bar or percentage)
  - Status badge
  - Next delivery date (if active)
- Section: "Contract Offers" — pending contract offers from stores
- Empty state: "No contracts yet. Build your reputation through spot sales to get contract offers!"

**Data Read:**
- `contracts` — WHERE farmer_id = me, joined with product, store, unit
- `contracts` — WHERE farmer_id IS NULL AND is_public = TRUE AND product_id IN (farmer's products) — open offers
- `contract_deliveries` — next upcoming delivery per contract

**Data Write:** None

**Navigation:**
- Tap contract → Contract Detail [id]
- Tap contract offer → Contract Detail (with accept/decline actions)

---

### 2.12 Contract Detail (Farmer View)

**Route:** `(farmer)/(tabs)/marketplace/contracts/[id].tsx`

**Purpose:** View contract details, delivery schedule, and fulfillment.

**UI Elements:**
- **Contract Header:**
  - Product name + variety
  - Store name + location
  - Status badge
  - Contract period
- **Terms Section:**
  - Quantity per delivery + unit
  - Price per unit with currency
  - Delivery frequency
  - Quality standards
  - Payment terms
- **Fulfillment Section:**
  - Total contracted quantity
  - Total delivered quantity
  - Fulfillment rate (progress bar)
- **Delivery Schedule:**
  - List of all contract_deliveries, each showing:
    - Expected date
    - Status (upcoming, due, delivered, confirmed, missed)
    - Expected vs actual quantity (if delivered)
    - Quality rating (if confirmed by store)
  - "Log Delivery" button on due deliveries
- **Actions (based on contract status):**
  - Open offer (not yet accepted): "Accept Contract" / "Decline Contract"
  - Active: "Log Delivery" (on due items)

**Data Read:**
- `contracts` — single contract WHERE id = [id]
- `contract_deliveries` — WHERE contract_id = [id], ordered by expected_date
- `stores` — store profile
- `products`, `units_of_measure`, `currencies`

**Data Write:**
- Accept contract: updates `contracts.farmer_id` = me, `status` = 'accepted'
- Decline contract: no write (farmer simply doesn't accept)
- Log delivery: updates `contract_deliveries` row (actual_date, actual_quantity, farmer_notes, status: 'delivered')
- Accepting contract also creates `cropping_plans` entry tagged as contracted (or prompts farmer to link existing plan)

**Navigation:**
- "Accept Contract" → confirmation modal → success, contract activates
- "Log Delivery" → delivery logging modal/form
- "Decline Contract" → confirmation → back to contracts list

---

### 2.13 My Orders — List View

**Route:** `(farmer)/(tabs)/orders/index.tsx`

**Tab:** Orders

**Purpose:** View all orders the farmer needs to fulfill.

**UI Elements:**
- Tab filters: Active | Completed | Cancelled | All
- List of OrderCards, each showing:
  - Order number
  - Source badge (Spot | Tender | Contract)
  - Store name
  - Product(s) + quantity + unit
  - Total value with currency
  - Delivery method
  - Expected delivery date
  - Status badge + OrderStatusTimeline (compact)
- Empty state: "No orders yet. List your produce to start receiving orders!"
- Pull-to-refresh

**Data Read:**
- `orders` — WHERE farmer_id = me, joined with store, product, unit
- `order_items` — for each order

**Real-time:** Subscribe to new orders + status changes

**Data Write:** None

**Navigation:**
- Tap order → Order Detail [id]

---

### 2.14 Order Detail (Farmer View)

**Route:** `(farmer)/(tabs)/orders/[id].tsx`

**Purpose:** View order details and update status.

**UI Elements:**
- **Order Header:**
  - Order number
  - Source badge (Spot / Tender / Contract)
  - Status badge
  - OrderStatusTimeline (visual step tracker)
- **Store Info:**
  - Store name, location
  - Delivery method
  - Delivery/collection address
  - Expected date
- **Items Section:**
  - List of order_items: product, variety, quantity, unit, price per unit, line total
  - Order subtotal with currency
  - Commission amount (if visible to farmer)
- **Payment Section:**
  - Payment status badge (unpaid / paid / confirmed)
  - Payment method
- **Notes Section:**
  - Farmer notes (editable)
  - Store notes (read-only, after delivery confirmation)
- **Store Review (if completed):**
  - Display review received from store
- **Action Buttons (based on current status):**
  - New: "Accept Order" / "Decline Order"
  - Accepted: "Mark as Preparing"
  - Preparing: "Mark as Ready"
  - Ready: "Mark as In Transit" (if farmer delivers) or "Ready for Collection"
  - Delivered: waiting for store confirmation
  - Confirmed: order complete, show review if received

**Data Read:**
- `orders` — single order WHERE id = [id] AND farmer_id = me
- `order_items` — WHERE order_id = [id]
- `stores` — store profile
- `reviews` — WHERE order_id = [id] (if exists)
- `products`, `units_of_measure`, `currencies`

**Data Write:**
- Status transitions: updates `orders.status`
- Farmer notes: updates `orders.farmer_notes`
- Decline order: updates status to 'cancelled'

**Offline Queue:** ✅ Yes (status updates)

**Navigation:**
- Status action buttons → update status, stay on screen with updated timeline

---

### 2.15 Farmer Profile

**Route:** `(farmer)/(tabs)/profile/index.tsx`

**Tab:** Profile

**Purpose:** View farmer's own profile, stats, and settings.

**UI Elements:**
- **Profile Header:**
  - Avatar photo
  - Full name
  - Farm name
  - Verification badge (✓ Verified)
  - Member since date
- **Ratings Summary:**
  - Overall rating (stars + number)
  - Quality rating
  - Reliability rating
  - Total reviews count
  - Total transactions count
  - Contract fulfillment rate
- **Quick Links:**
  - "My Products" → products I grow
  - "My Reviews" → reviews received
  - "Edit Profile" → edit form
  - "Edit Farm Details" → edit farm form
- **Account Section:**
  - "Switch Role" (if multi-role) → Role Switcher
  - "Notifications Settings"
  - "Log Out"

**Data Read:**
- `profiles` — current user
- `farmers` — current farmer record (all fields including ratings)
- `farmer_products` — count
- `reviews` — count

**Data Write:** None (read-only view)

**Navigation:**
- "My Products" → Products screen
- "My Reviews" → Reviews screen
- "Edit Profile" → Edit Profile form
- "Switch Role" → Role Switcher
- "Log Out" → clears session → Welcome screen

---

### 2.16 Farmer Notifications

**Route:** `(farmer)/notifications.tsx`

**Purpose:** Full notification feed.

**UI Elements:**
- List of NotificationCards, each showing:
  - Icon based on notification type
  - Title and body text
  - Timestamp (relative — "2 hours ago")
  - Unread indicator (dot or highlight)
- Mark all as read button
- Pull-to-refresh
- Tap notification → navigates to relevant screen

**Data Read:**
- `notifications` — WHERE recipient_id = me, ordered by created_at DESC
- Paginated (load more on scroll)

**Data Write:**
- Mark individual notification as read: updates `notifications.is_read = true`
- Mark all as read: bulk update

**Navigation:**
- Tap notification → routes based on `data` payload:
  - `order_placed_on_listing` → Order Detail
  - `new_tender_match` → Tender Detail
  - `contract_offer_received` → Contract Detail
  - `review_received` → Profile / Reviews
  - `farmer_approved` → Dashboard
  - `product_request_approved` → Listings / Create (to use new product)
  - etc.

---

## 3. STORE EXPERIENCE

Screens visible to authenticated users with active store role. Bottom tab navigation.

**Tab Bar:** Home | Browse | Procurement | Orders | Profile

---

### 3.1 Store Home / Dashboard

**Route:** `(store)/(tabs)/home.tsx`

**Tab:** Home

**Purpose:** At-a-glance overview of store procurement activity.

**UI Elements:**
- Welcome message: "Good morning, [business name]"
- Role switcher button (if multi-role — top right)
- **Quick Stats Cards:**
  - New listings from farmers (since last visit)
  - Open orders count (not yet confirmed delivery)
  - Active contracts count
  - Active tenders count
- **Upcoming Section:**
  - Next contract delivery expected (from contract_deliveries)
  - Tenders expiring soon
- **Recent Activity Feed:**
  - Last 5 notifications (new listings, tender offers, delivery confirmations)
- **Quick Actions:**
  - "Browse Listings" button
  - "+ New Tender" button
- Notification bell with unread count

**Data Read:**
- `stores` — current store profile
- `listings` — count of new active listings (since store's last login or last 24h)
- `orders` — count WHERE store_id = me AND status NOT IN ('confirmed', 'cancelled')
- `contracts` — count WHERE store_id = me AND status = 'active'
- `tenders` — count WHERE store_id = me AND status = 'active'
- `contract_deliveries` — next upcoming WHERE contract.store_id = me
- `notifications` — last 5 + unread count

**Real-time Subscriptions:**
- `listings` — new listings matching store interests
- `tender_offers` — new offers on store's tenders
- `notifications` — new notifications

**Navigation:**
- Stats cards → respective list screens
- "Browse Listings" → Browse Listings
- "+ New Tender" → Create Tender

---

### 3.2 Browse Farmer Listings

**Route:** `(store)/(tabs)/browse/index.tsx`

**Tab:** Browse

**Purpose:** Explore all available farmer produce listings.

**UI Elements:**
- **Search bar** at top
- **Filter bar:** Category, Product, Distance, Price range, Min farmer rating, Availability date
- **Sort options:** Nearest, Newest, Price (low→high), Price (high→low), Farmer rating
- **List/Grid toggle**
- List of ListingCards, each showing:
  - Product photo (thumbnail)
  - Product name + variety
  - Quantity available + unit
  - Price per unit with currency
  - Farmer name + avatar + rating stars
  - Farm location + distance from store
  - Availability window
  - Delivery options icons
- Pull-to-refresh
- Load more on scroll (pagination)
- Empty state: "No listings available right now. Check back soon or post a tender!"

**Data Read:**
- `listings` — WHERE status = 'active', with filters applied
- Joined: `products`, `product_varieties`, `units_of_measure`, `currencies`
- Joined: `farmers` (name, avatar, rating, location) + `profiles` (name)
- `listing_images` — first image per listing
- `stores` — current store location (for distance calculation)

**Data Write:** None

**Navigation:**
- Tap listing → Listing Detail [id] (store view)
- Filter/sort controls → re-query

---

### 3.3 Listing Detail + Place Order (Store View)

**Route:** `(store)/(tabs)/browse/[id].tsx`

**Purpose:** View full listing details and place an order.

**UI Elements:**
- **Image carousel** (all listing photos)
- **Product Info:**
  - Product name + variety
  - Quality grade
  - Description / notes
  - Availability: [from date] → [until date]
- **Pricing:**
  - Price per unit with currency (large, prominent)
  - Unit of measure
- **Quantity Available:**
  - Remaining / Total (with visual indicator)
- **Farmer Info Section:**
  - Farmer name + avatar
  - Farm name + location + distance
  - Overall rating (stars) + review count
  - Verification badge
  - "View Farmer Profile" link
- **Delivery Options:**
  - What the farmer offers (delivers / collects / either)
- **Place Order Section:**
  - Quantity to order (input — max = quantity_remaining)
  - Calculated total: [quantity × price] with currency
  - Delivery method selector (based on listing's delivery_options)
  - Expected delivery/collection date (date picker)
  - Notes (optional)
  - "Place Order" button

**Data Read:**
- `listings` — single listing WHERE id = [id] AND status = 'active'
- `listing_images` — all images
- `farmers` + `profiles` — farmer profile info
- `products`, `product_varieties`, `units_of_measure`, `currencies`

**Data Write:**
- Creates `orders` row (source: 'spot', listing_id, store_id, farmer_id, delivery_method, subtotal, commission)
- Creates `order_items` row
- **⚠️ Atomic decrement** of `listings.quantity_remaining`
- If quantity_remaining reaches 0, auto-update listing status to 'sold'
- Triggers notification to farmer (new order)

**Validation:**
- Quantity required, > 0, <= quantity_remaining
- Delivery method required
- Date required

**Navigation:**
- "Place Order" → confirmation modal → success → Order Detail
- "View Farmer Profile" → Farmer public profile view

---

### 3.4 Browse Cropping Plans

**Route:** `(store)/(tabs)/browse/cropping-plans.tsx`

**Purpose:** Forward visibility into what farmers are growing and when.

**UI Elements:**
- **Filter bar:** Product, Expected harvest date range, Location/Distance
- **Sort:** Soonest harvest, Nearest, Largest yield
- List of CroppingPlanCards (from all farmers), each showing:
  - Product name + variety
  - Farmer name + location + distance + rating
  - Date planted → Expected harvest date
  - Estimated yield + unit
  - Growing status badge
  - Contract tag: "🔒 Contracted" or "Available"
- Only shows plans where `is_contracted = false` (or all, with contracted ones marked)
- Pull-to-refresh

**Data Read:**
- `cropping_plans` — WHERE growing_status != 'harvested', from approved farmers
- Joined: `farmers`, `profiles`, `products`, `units_of_measure`

**Data Write:** None

**Navigation:**
- Tap plan → could open farmer profile or create a contract offer for that product/farmer

---

### 3.5 Procurement Hub

**Route:** `(store)/(tabs)/procurement/index.tsx`

**Tab:** Procurement

**Purpose:** Combined view of tenders and contracts for the store.

**UI Elements:**
- Two sub-tabs: **My Tenders** | **My Contracts**
- "+ New Tender" button
- "+ New Contract" button

**Navigation:**
- Sub-tabs switch between tenders and contracts views

---

### 3.6 My Tenders — List View

**Route:** `(store)/(tabs)/procurement/tenders/index.tsx`

**Purpose:** View all tenders posted by this store.

**UI Elements:**
- Tab filters: Active | Fulfilled | Expired | All
- List of TenderCards, each showing:
  - Product name + variety
  - Quantity needed + unit
  - Quantity fulfilled so far (progress bar)
  - Price range with currency (if set)
  - Date needed by
  - Number of offers received
  - Status badge
  - Time remaining
- Empty state: "No tenders yet. Post one to find farmers for your needs!"
- Pull-to-refresh

**Data Read:**
- `tenders` — WHERE store_id = me
- `tender_offers` — count per tender
- Joined: `products`, `units_of_measure`, `currencies`

**Data Write:** None

**Navigation:**
- Tap tender → Tender Detail [id]
- "+ New Tender" → Create Tender

---

### 3.7 Create Tender

**Route:** `(store)/(tabs)/procurement/tenders/create.tsx`

**Purpose:** Store posts a procurement request.

**UI Elements:**
- Product picker (from catalogue)
- Variety picker (optional)
- Quantity needed input + unit picker
- Price range (min and max inputs, optional) with currency
- Date needed by (date picker)
- Quality requirements textarea (optional)
- Delivery preference selector (farmer delivers / I'll collect / either)
- Tender expiry date (optional — when to stop accepting offers)
- "Post Tender" button

**Data Read:**
- `products`, `product_varieties`, `units_of_measure`, `currencies`
- `stores` — current store's country for currency

**Data Write:**
- Creates `tenders` row
- Triggers notifications to eligible farmers (matching product + location)

**Validation:**
- Product required
- Quantity required, > 0
- Date needed by required, must be in future
- If price range set, max >= min

**Navigation:**
- "Post Tender" → success toast → My Tenders list

---

### 3.8 Tender Detail + Review Offers (Store View)

**Route:** `(store)/(tabs)/procurement/tenders/[id].tsx`

**Purpose:** View tender details and manage farmer offers.

**UI Elements:**
- **Tender Info:**
  - Product, quantity, price range, date needed, quality requirements
  - Status badge
  - Fulfillment progress bar
- **Farmer Offers Section:**
  - List of offers received, each showing:
    - Farmer name + avatar + rating + location + distance
    - Quantity offered + price per unit with currency
    - Delivery date committed
    - Delivery method
    - Offer status (pending / accepted / declined)
    - "Accept" / "Decline" buttons (on pending offers)
  - Sort offers by: price (low→high), farmer rating, delivery date, quantity
- **Actions:**
  - "Close Tender" (if no longer needed)
  - "Edit Tender" (if no offers accepted yet)

**Data Read:**
- `tenders` — single tender WHERE id = [id] AND store_id = me
- `tender_offers` — WHERE tender_id = [id], joined with farmer profiles
- `farmers` + `profiles` — farmer info for each offer

**Data Write:**
- Accept offer: updates `tender_offers.status` = 'accepted' → creates `orders` row (source: 'tender')
- Decline offer: updates `tender_offers.status` = 'declined'
- **⚠️ Atomic increment** of `tenders.quantity_fulfilled` when accepting
- Triggers notification to farmer on accept/decline
- Close tender: updates `tenders.status` = 'cancelled'

**Navigation:**
- Accept offer → Order created → navigate to Order Detail
- Decline → stays on screen, offer updated
- Farmer name → Farmer public profile

---

### 3.9 My Contracts — List View (Store)

**Route:** `(store)/(tabs)/procurement/contracts/index.tsx`

**Purpose:** View all contracts this store has created.

**UI Elements:**
- Tab filters: Open (awaiting farmer) | Active | Completed | All
- List of ContractCards, each showing:
  - Product name + variety
  - Farmer name (or "Open — awaiting farmer" if not yet accepted)
  - Quantity per delivery + unit
  - Price per unit with currency
  - Delivery frequency
  - Contract period
  - Fulfillment rate (progress bar)
  - Next delivery date
  - Status badge
- Empty state: "No contracts yet. Create one to secure consistent supply!"
- Pull-to-refresh

**Data Read:**
- `contracts` — WHERE store_id = me
- Joined: `products`, `farmers`, `profiles`, `units_of_measure`, `currencies`
- `contract_deliveries` — next upcoming per contract

**Navigation:**
- Tap contract → Contract Detail [id]
- "+ New Contract" → Create Contract

---

### 3.10 Create Contract

**Route:** `(store)/(tabs)/procurement/contracts/create.tsx`

**Purpose:** Store creates a contract farming offer.

**UI Elements:**
- **Step 1 — Product & Quantity:**
  - Product picker
  - Variety picker (optional)
  - Quantity per delivery + unit picker
  - Delivery frequency selector (weekly / biweekly / monthly / custom)
  - Custom frequency input (days, if custom selected)
- **Step 2 — Terms:**
  - Price per unit with currency
  - Quality standards textarea (optional)
  - Payment terms selector (on delivery / weekly / monthly)
  - Contract start date
  - Contract end date
- **Step 3 — Target:**
  - Toggle: "Open to all eligible farmers" / "Send to specific farmer"
  - If specific: farmer search/picker (search by name, location, product)
- **Step 4 — Review & Publish:**
  - Summary of all terms
  - Calculated: total contracted quantity over period
  - "Publish Contract" button

**Data Read:**
- `products`, `product_varieties`, `units_of_measure`, `currencies`
- `farmers` — for farmer picker (approved farmers who grow the selected product)

**Data Write:**
- Creates `contracts` row (farmer_id: NULL if public, farmer_id if targeted)
- Triggers notifications to eligible farmers

**Validation:**
- Product required
- Quantity per delivery required, > 0
- Price required, > 0
- Delivery frequency required
- Start date required, must be in future
- End date required, must be after start date
- If sending to specific farmer, farmer must be selected

**Navigation:**
- "Publish Contract" → success → Contracts list

---

### 3.11 Contract Detail (Store View)

**Route:** `(store)/(tabs)/procurement/contracts/[id].tsx`

**Purpose:** View contract details, delivery schedule, and fulfillment tracking.

**UI Elements:**
- **Contract Header:**
  - Product + variety
  - Farmer name + rating (or "Open — awaiting farmer" if not accepted)
  - Status badge
  - Contract period
- **Terms Section:**
  - All contract terms (quantity, price, frequency, quality, payment)
- **Fulfillment Dashboard:**
  - Total contracted quantity
  - Total delivered quantity
  - Fulfillment rate (visual progress bar + percentage)
  - Variance alerts (deliveries where actual < expected)
- **Delivery Schedule:**
  - Table/list of all contract_deliveries:
    - Expected date
    - Status badge (upcoming / due / delivered / confirmed / missed)
    - Expected quantity
    - Actual quantity (if delivered)
    - Quality rating (input for store to rate)
    - "Confirm Delivery" button (on delivered items)
- **Actions:**
  - "Cancel Contract" (with confirmation)

**Data Read:**
- `contracts` — WHERE id = [id] AND store_id = me
- `contract_deliveries` — WHERE contract_id = [id]
- `farmers` + `profiles`
- `products`, `units_of_measure`, `currencies`

**Data Write:**
- Confirm delivery: updates `contract_deliveries.status` = 'confirmed', sets quality_rating
- Updates `contracts.total_delivered_qty` and `fulfillment_rate` (atomic)
- Cancel contract: updates `contracts.status` = 'cancelled'

**Navigation:**
- "Confirm Delivery" → inline update
- Farmer name → Farmer public profile

---

### 3.12 Store Orders — List View

**Route:** `(store)/(tabs)/orders/index.tsx`

**Tab:** Orders

**Purpose:** View all orders this store has placed.

**UI Elements:**
- Tab filters: Active | Completed | Cancelled | All
- Filter by: source (Spot / Tender / Contract), product, farmer
- List of OrderCards, each showing:
  - Order number
  - Source badge
  - Farmer name + rating
  - Product(s) + quantity + unit
  - Total value with currency
  - Delivery method
  - Expected date
  - Status badge
- Pull-to-refresh

**Data Read:**
- `orders` — WHERE store_id = me
- `order_items`, `farmers`, `profiles`, `products`, `units_of_measure`, `currencies`

**Real-time:** Subscribe to order status changes

**Navigation:**
- Tap order → Order Detail [id]

---

### 3.13 Order Detail (Store View)

**Route:** `(store)/(tabs)/orders/[id].tsx`

**Purpose:** View order details, confirm receipt, rate farmer.

**UI Elements:**
- **Order Header:**
  - Order number, source badge, status badge
  - OrderStatusTimeline (visual progress)
- **Farmer Info:**
  - Name, avatar, rating, location
- **Items Section:**
  - Product(s), quantity, unit, price per unit, line total
  - Order subtotal with currency
- **Delivery Info:**
  - Delivery method, date, address
- **Payment Section:**
  - Payment status badge
  - Payment method
  - "Mark as Paid" button (updates payment_status)
- **Receipt Confirmation (when status = 'delivered'):**
  - Actual quantity received (input per item)
  - Store notes textarea
  - "Confirm Receipt" button
- **Review Section (after confirmation):**
  - If no review yet: "Leave Review" button
  - If reviewed: display the review left

**Data Read:**
- `orders` — WHERE id = [id] AND store_id = me
- `order_items`, `farmers`, `profiles`, `products`, `units_of_measure`, `currencies`
- `reviews` — WHERE order_id = [id]

**Data Write:**
- Confirm receipt: updates `orders.status` = 'confirmed', `actual_qty_received`, `store_notes`
- Updates `order_items.actual_qty_received`
- Mark as paid: updates `orders.payment_status`
- Triggers farmer rating recalculation if review exists

**Navigation:**
- "Confirm Receipt" → inline update → "Leave Review" prompt
- "Leave Review" → Review Form
- "Mark as Paid" → inline update

---

### 3.14 Leave Review

**Route:** `(store)/(tabs)/orders/review/[id].tsx`

**Purpose:** Store rates and reviews a farmer after a completed order.

**UI Elements:**
- **Order Reference:**
  - Order number, product, farmer name
- **Rating Inputs:**
  - Overall rating (1-5 stars — tap to select)
  - Quality rating (1-5 stars)
  - Reliability rating (1-5 stars)
- **Written Review:**
  - Comment textarea (optional)
- "Submit Review" button

**Data Read:**
- `orders` — order details for context
- `farmers` — farmer name for display

**Data Write:**
- Creates `reviews` row (order_id, store_id, farmer_id, ratings, comment)
- Triggers farmer aggregate rating recalculation (Edge Function or trigger)
- Updates `farmers.total_reviews`, `farmers.total_transactions`, all avg ratings

**Validation:**
- All three ratings required (1-5)
- Comment optional

**Navigation:**
- "Submit Review" → success toast → back to Order Detail (now shows review)

---

### 3.15 Store Inventory (Basic)

**Route:** `(store)/(tabs)/inventory/index.tsx`

**Tab:** Accessible from dashboard or as sub-section

**Purpose:** Basic view of procured stock.

**UI Elements:**
- **Current Stock Section:**
  - List of products the store has received, grouped by product:
    - Product name
    - Total quantity received (sum of confirmed orders)
    - Last received date
    - Farmer source(s)
- **Incoming Section:**
  - Orders in transit or upcoming contract deliveries
  - Product, quantity, expected date, farmer
- **Simple Filters:** Product, date range
- Note: "Full inventory management coming soon"

**Data Read:**
- `orders` — WHERE store_id = me AND status = 'confirmed', grouped by product
- `order_items` — quantities
- `orders` — WHERE store_id = me AND status IN ('accepted', 'preparing', 'ready', 'in_transit')
- `contract_deliveries` — WHERE status = 'upcoming' AND contract.store_id = me

**Data Write:** None

**Navigation:**
- Tap product → could show order history for that product

---

### 3.16 Store Profile

**Route:** `(store)/(tabs)/profile/index.tsx`

**Tab:** Profile

**Purpose:** View and manage store profile.

**UI Elements:**
- **Profile Header:**
  - Store logo
  - Business name
  - Store type badge
  - Location
  - Member since
- **Stats:**
  - Total orders placed
  - Active contracts
  - Total farmers worked with
- **Quick Links:**
  - "Edit Store Details" → edit form
- **Account Section:**
  - "Switch Role" (if multi-role)
  - "Notification Settings"
  - "Log Out"

**Data Read:**
- `profiles`, `stores` — current store profile
- `orders` — count
- `contracts` — count
- `orders` — distinct farmer_id count

**Data Write:** None

**Navigation:**
- "Edit Store Details" → edit form
- "Switch Role" → Role Switcher
- "Log Out" → Welcome screen

---

### 3.17 Store Notifications

**Route:** `(store)/notifications.tsx`

**Purpose:** Full notification feed for store.

**UI Elements:** Same structure as Farmer Notifications (2.16), different notification types.

**Data Read:**
- `notifications` — WHERE recipient_id = me

**Data Write:**
- Mark as read

**Navigation:**
- Tap notification → routes based on type:
  - `new_listing_match` → Listing Detail (store view)
  - `tender_offer_received` → Tender Detail
  - `order_status_changed` → Order Detail
  - `contract_delivery_reminder` → Contract Detail
  - etc.

---

### 3.18 Edit Store Profile

**Route:** `(store)/(tabs)/profile/edit.tsx`

**Purpose:** Edit store business details.

**UI Elements:**
- Business name input
- Store type selector
- Location (GPS + manual)
- Country selector
- Contact phone
- Contact email
- Bio textarea
- Logo upload
- "Save Changes" button

**Data Read:**
- `stores`, `profiles` — current values
- `countries`

**Data Write:**
- Updates `stores` row
- Updates `profiles` row (if name/email/avatar changed)

**Navigation:**
- "Save Changes" → success toast → back to profile

---

### 3.19 Farmer Public Profile (Viewed by Store)

**Route:** Modal or separate screen accessible from listing detail, tender offers, etc.

**Purpose:** Store views a farmer's public profile.

**UI Elements:**
- **Profile Header:**
  - Avatar, name, farm name, location
  - Verification badge
  - Member since
- **Ratings:**
  - Overall, quality, reliability (stars + numbers)
  - Total reviews + transactions
  - Contract fulfillment rate
- **Products They Grow:**
  - List of products from farmer_products
- **Active Listings:**
  - ListingCards for their current active listings
- **Reviews:**
  - List of ReviewCards from other stores
- **Actions:**
  - "Send Contract Offer" → Create Contract (pre-filled with this farmer)

**Data Read:**
- `farmers` + `profiles` — farmer public profile
- `farmer_products` + `products` — what they grow
- `listings` — WHERE farmer_id = [id] AND status = 'active'
- `reviews` — WHERE farmer_id = [id], with store names

**Data Write:** None

**Navigation:**
- Tap listing → Listing Detail
- "Send Contract Offer" → Create Contract (farmer pre-selected)

---

## 4. SHARED SCREENS

---

### 4.1 Role Switcher

**Route:** `role-switcher.tsx`

**Purpose:** Allows multi-role users to switch between farmer and store experiences.

**UI Elements:**
- "Switch Role" heading
- Current active role highlighted
- List of user's roles:
  - 🌱 Farmer — [farm name] (tap to switch)
  - 🏪 Store — [business name] (tap to switch)
- Each role shows active/inactive state

**Data Read:**
- `user_roles` — WHERE profile_id = me AND is_active = true
- `farmers` — if has farmer role
- `stores` — if has store role

**Data Write:**
- No database write — switches are handled in app state (RoleProvider context)

**Navigation:**
- Select role → navigates to that role's home screen

---

### 4.2 Pending Approval Screen

**Route:** Shown within farmer experience when `verification_status = 'pending'`

**Purpose:** Tells newly registered farmers their application is under review.

**UI Elements:**
- Illustration (clock / waiting)
- "Application Under Review" heading
- "Your farmer application is being reviewed by our team. You'll receive a notification when it's approved."
- Application submitted date
- "What happens next?" expandable section:
  - "Our team will review your farm details"
  - "You'll receive a push notification and WhatsApp message when approved"
  - "Once approved, you can start listing your produce"
- "Contact Support" link
- "Log Out" button

**Data Read:**
- `farmers` — verification_status, created_at

**Data Write:** None

**Real-time:** Subscribe to `farmers` row changes — if status changes to 'approved', auto-navigate to Farmer Home

---

## 5. ADMIN PANEL SCREENS

Next.js web application. Sidebar navigation. All screens require admin role authentication.

---

### 5.1 Admin Dashboard

**Route:** `/`

**Purpose:** Platform overview and key metrics.

**UI Elements:**
- **Stat Cards Row:**
  - Total farmers (approved / pending / total)
  - Total stores (active)
  - Total listings (active)
  - Total orders (this month / all time)
  - Total transaction value (this month) with currency
  - Commission earned (this month) with currency
- **Charts:**
  - Orders over time (line chart — last 30 days)
  - Top products by transaction volume (bar chart)
- **Pending Actions:**
  - Farmer applications awaiting review (count + link)
  - Product requests awaiting review (count + link)
- **Recent Activity:**
  - Last 10 orders across platform

**Data Read:**
- Aggregated queries across `farmers`, `stores`, `listings`, `orders`, `order_items`
- `product_requests` — count WHERE status = 'pending'
- `farmers` — count WHERE verification_status = 'pending'

---

### 5.2 Farmer Applications

**Route:** `/farmers/applications`

**Purpose:** Review and approve/reject farmer registrations.

**UI Elements:**
- DataTable of pending applications:
  - Farmer name, farm name, location, country
  - Products they grow
  - Farm size
  - Submitted date
  - "Review" button per row
- Clicking "Review" opens detail panel or modal:
  - Full farmer profile details
  - Farm photos
  - Products selected
  - ID number / business registration
  - "Approve" button (with optional note)
  - "Reject" button (with required reason)
- Filters: status (pending / approved / rejected / all)

**Data Read:**
- `farmers` + `profiles` — with filters
- `farm_images`, `farmer_products` + `products`

**Data Write:**
- Approve: updates `farmers.verification_status` = 'approved', `verified_at`, `verified_by`
- Reject: updates `farmers.verification_status` = 'rejected', `rejection_reason`
- Triggers notification to farmer

---

### 5.3 All Farmers

**Route:** `/farmers`

**Purpose:** View and manage all farmers on the platform.

**UI Elements:**
- DataTable: name, farm name, location, country, status, rating, transactions, joined date
- Search by name or farm name
- Filter by: status, country, product, rating range
- Click row → Farmer Detail

**Data Read:**
- `farmers` + `profiles` — paginated, filtered

---

### 5.4 Farmer Detail (Admin)

**Route:** `/farmers/[id]`

**Purpose:** Full view of a farmer's profile, activity, and history.

**UI Elements:**
- **Profile Section:** all farmer details, farm photos, verification info
- **Products Tab:** what they grow
- **Listings Tab:** all listings (active, past)
- **Orders Tab:** all orders (as farmer)
- **Contracts Tab:** all contracts
- **Reviews Tab:** all reviews received
- **Actions:** Suspend / Reactivate farmer

**Data Read:**
- Everything related to this farmer across all tables

**Data Write:**
- Suspend: updates `farmers.verification_status` = 'suspended'
- Reactivate: updates back to 'approved'

---

### 5.5 All Stores

**Route:** `/stores`

**Purpose:** View and manage all stores.

**UI Elements:**
- DataTable: business name, type, location, country, status, orders count, joined date
- Search, filter
- Click row → Store Detail

---

### 5.6 Store Detail (Admin)

**Route:** `/stores/[id]`

**Purpose:** Full view of a store's profile and activity.

**UI Elements:**
- **Profile Section:** all store details
- **Orders Tab:** all orders placed
- **Tenders Tab:** all tenders posted
- **Contracts Tab:** all contracts created
- **Actions:** Deactivate / Activate store

---

### 5.7 Product Categories & Products

**Route:** `/catalogue`

**Purpose:** Manage the product catalogue.

**UI Elements:**
- **Categories Section:**
  - List of categories with product counts
  - "Add Category" button → inline form or modal
  - Edit / Deactivate per category
- **Products Section (filtered by selected category):**
  - DataTable: name, category, varieties count, active listings count
  - "Add Product" button → form/modal
  - Edit / Deactivate per product
  - Click product → Product detail with varieties management

**Data Read:**
- `product_categories`, `products`, `product_varieties`
- `listings` — count per product (for reference)

**Data Write:**
- CRUD on categories, products, varieties

---

### 5.8 Product Requests

**Route:** `/catalogue/requests`

**Purpose:** Review farmer requests to add new products.

**UI Elements:**
- DataTable of pending requests:
  - Farmer name, requested product name, suggested category, description, date
  - "Approve" / "Reject" buttons
- Approve flow:
  - Select or confirm category
  - Product name (editable — admin can fix spelling/naming)
  - "Approve & Add to Catalogue" → creates product, notifies farmer
- Reject flow:
  - Reason input (required)
  - "Reject" → notifies farmer with reason

**Data Read:**
- `product_requests` — WHERE status = 'pending'
- `farmers` + `profiles` — requester info
- `product_categories` — for category assignment

**Data Write:**
- Approve: creates `products` row, updates `product_requests.status` = 'approved', `created_product_id`
- Reject: updates `product_requests.status` = 'rejected', `admin_notes`
- Triggers notification to farmer

---

### 5.9 Units of Measure

**Route:** `/catalogue/units`

**Purpose:** Manage units of measure.

**UI Elements:**
- DataTable: name, abbreviation, context, active status
- "Add Unit" button → form/modal
- Edit / Deactivate per unit

**Data Read:** `units_of_measure`
**Data Write:** CRUD on units

---

### 5.10 All Orders

**Route:** `/transactions`

**Purpose:** View all orders across the platform.

**UI Elements:**
- DataTable: order number, store, farmer, products, total value, currency, source, status, payment status, date
- Search by order number
- Filter by: store, farmer, product, source, status, payment status, date range, country
- Export to CSV (optional)
- Click row → Order Detail

**Data Read:**
- `orders` + `order_items` + `stores` + `farmers` + `profiles` + `products` — paginated

---

### 5.11 Order Detail (Admin)

**Route:** `/transactions/[id]`

**Purpose:** Full order detail view for admin oversight.

**UI Elements:**
- All order details (same data as store/farmer views combined)
- Commission details
- Full status history
- Review (if exists)
- No edit actions (admin is read-only on orders unless needed for dispute resolution)

---

### 5.12 All Contracts (Admin)

**Route:** `/transactions/contracts`

**Purpose:** View all contracts across the platform.

**UI Elements:**
- DataTable: store, farmer, product, quantity, price, frequency, period, fulfillment rate, status
- Filter by: store, farmer, product, status, country
- Click row → Contract Detail

---

### 5.13 All Tenders (Admin)

**Route:** `/transactions/tenders`

**Purpose:** View all tenders across the platform.

**UI Elements:**
- DataTable: store, product, quantity needed, quantity fulfilled, offers count, status, date
- Filter by: store, product, status
- Click row → Tender Detail

---

### 5.14 Platform Settings

**Route:** `/settings`

**Purpose:** Manage global platform configuration.

**UI Elements:**
- **Commission Settings:**
  - Commission rate input (percentage)
  - "Save" button
- **Platform Info:**
  - Platform name
  - Support phone
  - Support email
- **Feature Flags:**
  - Farmer approval required (toggle)
- Each setting editable inline with save

**Data Read:** `platform_settings` — all rows
**Data Write:** Updates `platform_settings` rows

---

### 5.15 Currencies Management

**Route:** `/settings/currencies`

**Purpose:** Manage supported currencies.

**UI Elements:**
- DataTable: code, name, symbol, decimal precision, active status
- "Add Currency" button
- Edit / Activate / Deactivate per currency

**Data Read:** `currencies`
**Data Write:** CRUD on currencies

---

### 5.16 Countries Management

**Route:** `/settings/countries`

**Purpose:** Manage countries the platform operates in.

**UI Elements:**
- DataTable: code, name, default currency, active status
- "Add Country" button
- Edit / Activate / Deactivate per country

**Data Read:** `countries` + `currencies`
**Data Write:** CRUD on countries

---

## 6. SCREEN-TO-TABLE DATA MAP

Quick reference: which screens read/write to which tables.

### Most Accessed Tables (Read)

| Table | Screens That Read It |
|---|---|
| profiles | Nearly all screens (user context) |
| farmers | Dashboard, listings, browse, contracts, orders, reviews, admin |
| stores | Tenders, contracts, orders, admin |
| products | Every form with product picker, browse, admin catalogue |
| listings | Farmer listings, store browse, farmer home, store home |
| orders | Farmer orders, store orders, dashboards, admin |
| notifications | Both notification screens, both dashboards |
| contracts | Marketplace, procurement, cropping plans, admin |
| tenders | Marketplace, procurement, admin |
| currencies | Every screen that displays prices |
| units_of_measure | Every screen that displays quantities |

### Most Written Tables

| Table | Key Write Screens |
|---|---|
| profiles | Registration |
| user_roles | Registration |
| farmers | Registration, admin approval |
| stores | Registration |
| listings | Create listing, place order (quantity decrement) |
| orders | Place order, accept tender offer, contract delivery, status updates |
| order_items | Place order |
| tenders | Create tender, accept offer (fulfillment increment) |
| tender_offers | Submit offer, accept/decline |
| contracts | Create contract, accept, delivery tracking |
| contract_deliveries | Delivery logging, confirmation |
| reviews | Leave review |
| notifications | Every action that triggers a notification |
| cropping_plans | Create/update plan, accept contract |
| product_requests | Request new product, admin review |

---

## 7. REAL-TIME SUBSCRIPTIONS MAP

Which screens need live data updates via Supabase real-time.

| Subscription | Channel | Screens That Listen |
|---|---|---|
| New notifications | `notifications` WHERE recipient_id = me | Both dashboards, notification bell |
| New orders for farmer | `orders` WHERE farmer_id = me | Farmer dashboard, farmer orders |
| Order status changes | `orders` WHERE store_id = me OR farmer_id = me | Both order lists, order details |
| New listings | `listings` WHERE status = 'active' | Store dashboard, store browse |
| New tender offers | `tender_offers` WHERE tender.store_id = me | Store tender detail |
| New tenders | `tenders` WHERE status = 'active' | Farmer marketplace |
| Contract delivery updates | `contract_deliveries` WHERE contract.farmer_id = me | Farmer contract detail |
| Farmer approval status | `farmers` WHERE id = me | Pending approval screen |

---

*Document version: 1.0*
*Last updated: February 2025*
*Platform: ReKamoso AgriMart*
*Companion to: PROJECT_BRIEF.md, DATABASE_SCHEMA.md, and PROJECT_STRUCTURE.md*
