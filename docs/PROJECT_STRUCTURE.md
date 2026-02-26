# ReKamoso AgriMart — Project Structure & Conventions

## Farmer → Store Platform (Phase 1)

---

## 1. Repository Structure

The project uses a **monorepo** approach — all codebases live in a single repository. This simplifies sharing types, constants, and configuration between the Expo app and the admin panel.

```
rekamoso-agrimart/
│
├── apps/
│   ├── mobile/                    # Expo app (Farmer + Store — iOS, Android, Web)
│   └── admin/                     # Next.js admin panel (Web only)
│
├── packages/
│   ├── shared/                    # Shared TypeScript types, constants, utilities
│   │   ├── types/                 # Shared type definitions (database types, enums)
│   │   ├── constants/             # Shared constants (order statuses, role names, etc.)
│   │   ├── utils/                 # Shared utility functions (formatting, validation)
│   │   └── index.ts
│   │
│   └── supabase/                  # Supabase client config, generated types, queries
│       ├── client.ts              # Supabase client initialization
│       ├── types/                 # Auto-generated database types (from Supabase CLI)
│       ├── queries/               # Reusable query functions (used by both apps)
│       └── index.ts
│
├── supabase/                      # Supabase project configuration
│   ├── migrations/                # SQL migration files (schema changes)
│   ├── seed.sql                   # Seed data (categories, products, units, currencies)
│   ├── functions/                 # Supabase Edge Functions
│   │   ├── send-notification/     # Push + WhatsApp notification handler
│   │   ├── generate-order-number/ # Auto-generate order numbers
│   │   └── recalculate-ratings/   # Recalculate farmer aggregate ratings
│   └── config.toml                # Supabase local dev config
│
├── docs/                          # Project documentation
│   ├── PROJECT_BRIEF.md           # Full project brief
│   ├── DATABASE_SCHEMA.md         # Database schema document
│   ├── PROJECT_STRUCTURE.md       # This document
│   ├── SCREEN_MAP.md              # Screen-by-screen breakdown (next doc)
│   └── ARCHITECTURE.md            # Technical architecture reference
│
├── .gitignore
├── package.json                   # Root workspace config
├── tsconfig.base.json             # Base TypeScript config (shared)
└── README.md                      # Project overview and setup instructions
```

---

## 2. Mobile App Structure (Expo)

Located at `apps/mobile/`. This is a single Expo app that serves both **farmer** and **store** experiences based on the user's role(s).

Uses **Expo Router** (file-based routing) for navigation.

```
apps/mobile/
├── app/                           # Expo Router — file-based routing
│   ├── _layout.tsx                # Root layout (providers, auth gate, theme)
│   ├── index.tsx                  # Entry point — redirects based on auth state
│   │
│   ├── (auth)/                    # Auth screens (unauthenticated users)
│   │   ├── _layout.tsx            # Auth layout (no bottom tabs)
│   │   ├── welcome.tsx            # Welcome / landing screen
│   │   ├── login.tsx              # Phone number + OTP login
│   │   ├── verify-otp.tsx         # OTP verification screen
│   │   ├── register.tsx           # Role selection (Farmer or Store)
│   │   ├── register-farmer.tsx    # Farmer registration form
│   │   └── register-store.tsx     # Store registration form
│   │
│   ├── (farmer)/                  # Farmer experience (role: farmer)
│   │   ├── _layout.tsx            # Farmer tab layout (bottom tabs)
│   │   ├── (tabs)/
│   │   │   ├── home.tsx           # Farmer dashboard / home
│   │   │   ├── listings/
│   │   │   │   ├── index.tsx      # My listings (list view)
│   │   │   │   ├── create.tsx     # Create new listing
│   │   │   │   └── [id].tsx       # View/edit single listing
│   │   │   ├── cropping-plans/
│   │   │   │   ├── index.tsx      # My cropping plans (list/timeline)
│   │   │   │   ├── create.tsx     # Add new cropping plan entry
│   │   │   │   └── [id].tsx       # View/edit single plan
│   │   │   ├── marketplace/
│   │   │   │   ├── index.tsx      # Tenders + contracts combined view
│   │   │   │   ├── tenders/
│   │   │   │   │   ├── index.tsx  # Browse active tenders
│   │   │   │   │   ├── [id].tsx   # View tender detail + submit offer
│   │   │   │   │   └── my-offers.tsx # My tender offers
│   │   │   │   └── contracts/
│   │   │   │       ├── index.tsx  # My contracts (active, completed)
│   │   │   │       └── [id].tsx   # View contract detail + deliveries
│   │   │   ├── orders/
│   │   │   │   ├── index.tsx      # My orders (all statuses)
│   │   │   │   └── [id].tsx       # Order detail + status updates
│   │   │   └── profile/
│   │   │       ├── index.tsx      # Farmer profile + farm info
│   │   │       ├── edit.tsx       # Edit profile / farm details
│   │   │       ├── reviews.tsx    # My reviews (received from stores)
│   │   │       └── products.tsx   # My products (what I grow)
│   │   └── notifications.tsx      # Farmer notifications
│   │
│   ├── (store)/                   # Store experience (role: store)
│   │   ├── _layout.tsx            # Store tab layout (bottom tabs)
│   │   ├── (tabs)/
│   │   │   ├── home.tsx           # Store dashboard / home
│   │   │   ├── browse/
│   │   │   │   ├── index.tsx      # Browse farmer listings
│   │   │   │   ├── [id].tsx       # Listing detail + place order
│   │   │   │   └── cropping-plans.tsx # Browse farmer cropping plans
│   │   │   ├── procurement/
│   │   │   │   ├── index.tsx      # Procurement hub (tenders + contracts)
│   │   │   │   ├── tenders/
│   │   │   │   │   ├── index.tsx  # My tenders (active, fulfilled)
│   │   │   │   │   ├── create.tsx # Create new tender
│   │   │   │   │   ├── [id].tsx   # Tender detail + farmer offers
│   │   │   │   │   └── offers/
│   │   │   │   │       └── [id].tsx # Review individual offer
│   │   │   │   └── contracts/
│   │   │   │       ├── index.tsx  # My contracts (all statuses)
│   │   │   │       ├── create.tsx # Create new contract offer
│   │   │   │       └── [id].tsx   # Contract detail + delivery tracking
│   │   │   ├── orders/
│   │   │   │   ├── index.tsx      # All orders (spot + tender + contract)
│   │   │   │   ├── [id].tsx       # Order detail + confirm receipt
│   │   │   │   └── review/
│   │   │   │       └── [id].tsx   # Leave review for farmer
│   │   │   ├── inventory/
│   │   │   │   └── index.tsx      # Basic inventory view (procured stock)
│   │   │   └── profile/
│   │   │       ├── index.tsx      # Store profile
│   │   │       └── edit.tsx       # Edit store details
│   │   └── notifications.tsx      # Store notifications
│   │
│   └── role-switcher.tsx          # Role switcher (for multi-role users)
│
├── components/                    # Reusable UI components
│   ├── ui/                        # Base UI components (design system)
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   ├── Input.tsx
│   │   ├── Select.tsx
│   │   ├── Badge.tsx
│   │   ├── Modal.tsx
│   │   ├── Toast.tsx
│   │   ├── Avatar.tsx
│   │   ├── Rating.tsx             # Star rating display/input
│   │   ├── EmptyState.tsx         # Empty list placeholder
│   │   ├── LoadingSpinner.tsx
│   │   └── OfflineBanner.tsx      # "You're offline" indicator
│   │
│   ├── forms/                     # Form components
│   │   ├── PhoneInput.tsx         # Phone number input with country code
│   │   ├── OTPInput.tsx           # OTP code input
│   │   ├── ProductPicker.tsx      # Standardized product dropdown
│   │   ├── VarietyPicker.tsx      # Product variety selector
│   │   ├── UnitPicker.tsx         # Unit of measure dropdown
│   │   ├── QuantityInput.tsx      # Numeric quantity input with unit
│   │   ├── PriceInput.tsx         # Price input with currency symbol
│   │   ├── DatePicker.tsx         # Date selection
│   │   ├── LocationPicker.tsx     # GPS / address picker
│   │   ├── ImageUploader.tsx      # Photo upload (camera + gallery)
│   │   └── DeliveryMethodPicker.tsx # Delivery option selector
│   │
│   ├── cards/                     # Card components for list views
│   │   ├── ListingCard.tsx        # Produce listing card
│   │   ├── TenderCard.tsx         # Tender request card
│   │   ├── ContractCard.tsx       # Contract summary card
│   │   ├── OrderCard.tsx          # Order summary card
│   │   ├── CroppingPlanCard.tsx   # Cropping plan entry card
│   │   ├── FarmerCard.tsx         # Farmer profile summary card
│   │   ├── ReviewCard.tsx         # Review display card
│   │   └── NotificationCard.tsx   # Notification item card
│   │
│   ├── layout/                    # Layout components
│   │   ├── ScreenWrapper.tsx      # Standard screen container (safe area, scroll)
│   │   ├── Header.tsx             # Screen header
│   │   ├── TabBar.tsx             # Custom bottom tab bar (if customizing)
│   │   └── SectionHeader.tsx      # Section title within a screen
│   │
│   └── shared/                    # Shared feature components
│       ├── OrderStatusBadge.tsx   # Order status pill/badge
│       ├── OrderStatusTimeline.tsx # Visual order progress tracker
│       ├── ContractStatusBadge.tsx
│       ├── VerificationBadge.tsx  # Farmer verification status
│       ├── CurrencyDisplay.tsx    # Formats price with correct currency symbol
│       ├── QuantityDisplay.tsx    # Formats quantity with unit abbreviation
│       ├── RoleSwitcher.tsx       # Role switch button/modal
│       └── ProductRequestModal.tsx # "Request to add product" modal
│
├── hooks/                         # Custom React hooks
│   ├── useAuth.ts                 # Authentication state and actions
│   ├── useProfile.ts             # Current user profile
│   ├── useRoles.ts               # User roles and active role
│   ├── useListings.ts            # Listing CRUD operations
│   ├── useCroppingPlans.ts       # Cropping plan CRUD
│   ├── useTenders.ts             # Tender operations
│   ├── useContracts.ts           # Contract operations
│   ├── useOrders.ts              # Order operations
│   ├── useNotifications.ts       # Notification feed and mark-as-read
│   ├── useProducts.ts            # Product catalogue data
│   ├── useUnits.ts               # Units of measure data
│   ├── useCurrency.ts            # Currency formatting based on user's country
│   ├── useLocation.ts            # GPS location
│   ├── useImageUpload.ts         # Image upload to Supabase Storage
│   ├── useNetworkStatus.ts       # Online/offline detection
│   ├── useOfflineQueue.ts        # Offline action queue management
│   └── useRealtimeSubscription.ts # Supabase real-time listeners
│
├── services/                      # API service layer
│   ├── auth.service.ts            # Auth API calls (login, register, OTP)
│   ├── farmer.service.ts          # Farmer profile operations
│   ├── store.service.ts           # Store profile operations
│   ├── listing.service.ts         # Listing CRUD + atomic quantity updates
│   ├── cropping-plan.service.ts   # Cropping plan CRUD
│   ├── tender.service.ts          # Tender CRUD + offer management
│   ├── contract.service.ts        # Contract CRUD + delivery tracking
│   ├── order.service.ts           # Order CRUD + status transitions
│   ├── review.service.ts          # Review creation + rating aggregation
│   ├── notification.service.ts    # Notification operations
│   ├── product.service.ts         # Product catalogue + request to add
│   ├── upload.service.ts          # Image upload to Supabase Storage
│   └── offline-queue.service.ts   # Offline queue sync logic
│
├── providers/                     # React Context providers
│   ├── AuthProvider.tsx           # Authentication context
│   ├── RoleProvider.tsx           # Active role context
│   ├── ThemeProvider.tsx          # Theme / design system context
│   ├── NotificationProvider.tsx   # Push notification setup + listeners
│   └── NetworkProvider.tsx        # Online/offline status context
│
├── theme/                         # Design system / theming
│   ├── colors.ts                  # Color palette
│   ├── typography.ts              # Font families, sizes, weights
│   ├── spacing.ts                 # Spacing scale
│   ├── shadows.ts                 # Shadow definitions
│   ├── borderRadius.ts            # Border radius scale
│   └── index.ts                   # Combined theme export
│
├── utils/                         # App-specific utilities
│   ├── formatting.ts              # Price, date, quantity formatters
│   ├── validation.ts              # Form validation helpers
│   ├── storage.ts                 # AsyncStorage / MMKV helpers
│   ├── notifications.ts           # Push notification registration + handling
│   └── permissions.ts             # Camera, location permission helpers
│
├── assets/                        # Static assets
│   ├── images/                    # App images, illustrations
│   ├── icons/                     # Custom icons (if not using library)
│   └── fonts/                     # Custom fonts
│
├── app.json                       # Expo app configuration
├── eas.json                       # EAS Build configuration
├── babel.config.js
├── metro.config.js
├── tsconfig.json                  # Extends ../../tsconfig.base.json
├── tailwind.config.js             # If using NativeWind (Tailwind for RN)
└── package.json
```

### Navigation Structure

**Farmer Bottom Tabs:**
```
Home | Listings | Marketplace | Orders | Profile
```

**Store Bottom Tabs:**
```
Home | Browse | Procurement | Orders | Profile
```

**Auth Flow (no tabs):**
```
Welcome → Login → Verify OTP → Register (role select) → Register Form → Pending Approval (farmers)
```

---

## 3. Admin Panel Structure (Next.js)

Located at `apps/admin/`. Web-only admin dashboard for platform management.

Uses **Next.js App Router** (file-based routing).

```
apps/admin/
├── app/                           # Next.js App Router
│   ├── layout.tsx                 # Root layout (sidebar nav, auth gate)
│   ├── page.tsx                   # Dashboard home (stats overview)
│   │
│   ├── farmers/
│   │   ├── page.tsx               # All farmers (list + filter by status)
│   │   ├── [id]/
│   │   │   └── page.tsx           # Farmer detail (profile, activity, reviews)
│   │   └── applications/
│   │       └── page.tsx           # Pending applications queue
│   │
│   ├── stores/
│   │   ├── page.tsx               # All stores (list)
│   │   └── [id]/
│   │       └── page.tsx           # Store detail (profile, activity)
│   │
│   ├── catalogue/
│   │   ├── page.tsx               # Product categories overview
│   │   ├── products/
│   │   │   ├── page.tsx           # All products (list + manage)
│   │   │   └── [id]/
│   │   │       └── page.tsx       # Product detail (varieties, edit)
│   │   ├── requests/
│   │   │   └── page.tsx           # Product add requests (pending queue)
│   │   └── units/
│   │       └── page.tsx           # Units of measure management
│   │
│   ├── transactions/
│   │   ├── page.tsx               # All orders (filterable list)
│   │   ├── [id]/
│   │   │   └── page.tsx           # Order detail
│   │   ├── contracts/
│   │   │   ├── page.tsx           # All contracts overview
│   │   │   └── [id]/
│   │   │       └── page.tsx       # Contract detail
│   │   └── tenders/
│   │       ├── page.tsx           # All tenders overview
│   │       └── [id]/
│   │           └── page.tsx       # Tender detail
│   │
│   ├── settings/
│   │   ├── page.tsx               # Platform settings (commission, defaults)
│   │   ├── currencies/
│   │   │   └── page.tsx           # Manage currencies
│   │   └── countries/
│   │       └── page.tsx           # Manage countries
│   │
│   ├── analytics/
│   │   └── page.tsx               # Basic analytics dashboard
│   │
│   └── login/
│       └── page.tsx               # Admin login
│
├── components/                    # Admin UI components
│   ├── ui/                        # Base components (shadcn/ui based)
│   │   ├── Button.tsx
│   │   ├── Table.tsx
│   │   ├── DataTable.tsx          # Sortable, filterable data table
│   │   ├── Card.tsx
│   │   ├── Badge.tsx
│   │   ├── Modal.tsx
│   │   ├── Input.tsx
│   │   ├── Select.tsx
│   │   ├── Tabs.tsx
│   │   ├── Pagination.tsx
│   │   └── StatCard.tsx           # Dashboard metric card
│   │
│   ├── layout/
│   │   ├── Sidebar.tsx            # Navigation sidebar
│   │   ├── Header.tsx             # Top header with admin info
│   │   ├── PageHeader.tsx         # Page title + actions bar
│   │   └── BreadCrumbs.tsx
│   │
│   └── features/
│       ├── FarmerApplicationCard.tsx
│       ├── ProductRequestCard.tsx
│       ├── OrderSummaryRow.tsx
│       ├── AnalyticsChart.tsx
│       └── ActivityFeed.tsx
│
├── hooks/                         # Admin-specific hooks
│   ├── useAdminAuth.ts
│   ├── useFarmers.ts
│   ├── useStores.ts
│   ├── useProducts.ts
│   ├── useOrders.ts
│   ├── useAnalytics.ts
│   └── usePagination.ts
│
├── services/                      # Admin API service layer
│   ├── admin-auth.service.ts
│   ├── farmer-management.service.ts
│   ├── store-management.service.ts
│   ├── catalogue-management.service.ts
│   ├── order-management.service.ts
│   └── analytics.service.ts
│
├── public/                        # Static assets
│   └── logo.svg
│
├── tailwind.config.js             # Tailwind CSS config
├── tsconfig.json                  # Extends ../../tsconfig.base.json
├── next.config.js
└── package.json
```

### Admin Sidebar Navigation

```
📊 Dashboard
👨‍🌾 Farmers
   ├── All Farmers
   └── Applications
🏪 Stores
📦 Catalogue
   ├── Categories & Products
   ├── Product Requests
   └── Units of Measure
💰 Transactions
   ├── Orders
   ├── Contracts
   └── Tenders
📈 Analytics
⚙️ Settings
   ├── Platform Settings
   ├── Currencies
   └── Countries
```

---

## 4. Shared Package Structure

Located at `packages/shared/`. Shared code used by both the Expo app and admin panel.

```
packages/shared/
├── types/
│   ├── database.ts                # Core database row types (mirrors Supabase)
│   ├── enums.ts                   # Shared enums (statuses, roles, etc.)
│   ├── api.ts                     # API request/response types
│   └── index.ts
│
├── constants/
│   ├── roles.ts                   # User roles: 'farmer', 'store', 'admin'
│   ├── order-statuses.ts          # Order status values and labels
│   ├── contract-statuses.ts       # Contract status values and labels
│   ├── tender-statuses.ts         # Tender status values and labels
│   ├── listing-statuses.ts        # Listing status values and labels
│   ├── verification-statuses.ts   # Farmer verification status values
│   ├── delivery-methods.ts        # Delivery method options
│   ├── growing-statuses.ts        # Cropping plan growing statuses
│   ├── notification-types.ts      # All notification type constants
│   └── index.ts
│
├── utils/
│   ├── currency.ts                # Currency formatting: formatPrice(amount, currencyCode)
│   ├── date.ts                    # Date formatting helpers
│   ├── quantity.ts                # Quantity + unit formatting
│   ├── validation.ts              # Shared validation rules (phone, email, etc.)
│   └── index.ts
│
├── package.json
├── tsconfig.json
└── index.ts                       # Re-exports everything
```

### Shared Enums Example

```typescript
// packages/shared/constants/order-statuses.ts

export const ORDER_STATUSES = {
  NEW: 'new',
  ACCEPTED: 'accepted',
  PREPARING: 'preparing',
  READY: 'ready',
  IN_TRANSIT: 'in_transit',
  DELIVERED: 'delivered',
  CONFIRMED: 'confirmed',
  CANCELLED: 'cancelled',
} as const;

export const ORDER_STATUS_LABELS: Record<string, string> = {
  new: 'New',
  accepted: 'Accepted',
  preparing: 'Preparing',
  ready: 'Ready for Pickup',
  in_transit: 'In Transit',
  delivered: 'Delivered',
  confirmed: 'Confirmed',
  cancelled: 'Cancelled',
};

export type OrderStatus = typeof ORDER_STATUSES[keyof typeof ORDER_STATUSES];
```

### Shared Types Example

```typescript
// packages/shared/types/database.ts

export interface Profile {
  id: string;
  phone: string;
  email: string | null;
  full_name: string;
  avatar_url: string | null;
  created_at: string;
  updated_at: string;
}

export interface UserRole {
  id: string;
  profile_id: string;
  role: 'farmer' | 'store' | 'admin';
  is_active: boolean;
  created_at: string;
}

export interface Farmer {
  id: string;
  profile_id: string;
  farm_name: string;
  farm_location_lat: number | null;
  farm_location_lng: number | null;
  farm_address: string | null;
  country_id: string | null;
  farm_size: string | null;
  farm_size_unit: string | null;
  verification_status: 'pending' | 'approved' | 'rejected' | 'suspended';
  avg_overall_rating: number;
  avg_quality_rating: number;
  avg_reliability_rating: number;
  total_reviews: number;
  total_transactions: number;
  // ... etc
}

export interface Listing {
  id: string;
  farmer_id: string;
  product_id: string;
  variety_id: string | null;
  quantity: number;
  quantity_remaining: number;
  unit_id: string;
  price_per_unit: number;
  currency_code: string;
  quality_grade: string | null;
  available_from: string;
  available_until: string;
  delivery_options: 'farmer_delivers' | 'store_collects' | 'either';
  status: 'draft' | 'active' | 'sold' | 'expired' | 'cancelled';
  // ... etc
}

// Full types for all 26 tables follow the same pattern
```

---

## 5. Supabase Package Structure

Located at `packages/supabase/`. Centralized Supabase client and query functions.

```
packages/supabase/
├── client.ts                      # Supabase client initialization
├── types/
│   └── database.types.ts          # Auto-generated by: supabase gen types typescript
│
├── queries/
│   ├── profiles.ts                # Profile queries
│   ├── farmers.ts                 # Farmer queries (CRUD, search, filter)
│   ├── stores.ts                  # Store queries
│   ├── listings.ts                # Listing queries (with atomic quantity updates)
│   ├── cropping-plans.ts          # Cropping plan queries
│   ├── tenders.ts                 # Tender queries (with atomic fulfillment updates)
│   ├── tender-offers.ts           # Tender offer queries
│   ├── contracts.ts               # Contract queries
│   ├── contract-deliveries.ts     # Contract delivery queries
│   ├── orders.ts                  # Order queries (with order number generation)
│   ├── reviews.ts                 # Review queries
│   ├── notifications.ts           # Notification queries
│   ├── products.ts                # Product catalogue queries
│   ├── product-requests.ts        # Product request queries
│   ├── units.ts                   # Units of measure queries
│   └── currencies.ts              # Currency and country queries
│
├── realtime/
│   ├── listings.ts                # Real-time subscription for new/updated listings
│   ├── orders.ts                  # Real-time subscription for order status changes
│   ├── notifications.ts           # Real-time subscription for new notifications
│   └── tenders.ts                 # Real-time subscription for new tenders
│
├── storage/
│   └── upload.ts                  # File upload helpers for each bucket
│
├── package.json
├── tsconfig.json
└── index.ts
```

### Supabase Client Example

```typescript
// packages/supabase/client.ts

import { createClient } from '@supabase/supabase-js';
import { Database } from './types/database.types';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey);
```

### Atomic Query Example

```typescript
// packages/supabase/queries/listings.ts

/**
 * Place an order on a listing — uses atomic decrement to prevent overselling.
 * Returns the updated listing if successful, null if insufficient quantity.
 *
 * ⚠️ CONCURRENCY: This MUST use atomic SQL, never read-then-write.
 * See DATABASE_SCHEMA.md Section 13 for full explanation.
 */
export async function decrementListingQuantity(
  listingId: string,
  orderedQuantity: number
) {
  const { data, error } = await supabase.rpc('decrement_listing_quantity', {
    p_listing_id: listingId,
    p_ordered_qty: orderedQuantity,
  });

  if (error) throw error;
  return data; // null means insufficient quantity
}
```

---

## 6. Supabase Project Structure

Located at root `supabase/`. Contains migrations, seed data, and Edge Functions.

```
supabase/
├── migrations/
│   ├── 00001_create_profiles.sql
│   ├── 00002_create_user_roles.sql
│   ├── 00003_create_currencies_countries.sql
│   ├── 00004_create_farmers.sql
│   ├── 00005_create_farm_images.sql
│   ├── 00006_create_stores.sql
│   ├── 00007_create_admin_users.sql
│   ├── 00008_create_product_categories.sql
│   ├── 00009_create_products.sql
│   ├── 00010_create_product_varieties.sql
│   ├── 00011_create_product_requests.sql
│   ├── 00012_create_units_of_measure.sql
│   ├── 00013_create_farmer_products.sql
│   ├── 00014_create_listings.sql
│   ├── 00015_create_listing_images.sql
│   ├── 00016_create_cropping_plans.sql
│   ├── 00017_create_tenders.sql
│   ├── 00018_create_tender_offers.sql
│   ├── 00019_create_contracts.sql
│   ├── 00020_create_contract_deliveries.sql
│   ├── 00021_create_orders.sql
│   ├── 00022_create_order_items.sql
│   ├── 00023_create_reviews.sql
│   ├── 00024_create_notifications.sql
│   ├── 00025_create_platform_settings.sql
│   ├── 00026_create_indexes.sql
│   ├── 00027_create_rls_policies.sql
│   ├── 00028_create_triggers.sql
│   └── 00029_create_rpc_functions.sql  # Atomic operations (decrement_listing_quantity, etc.)
│
├── seed.sql                       # Seed data for all lookup tables
│   # Contents:
│   # - Currencies (BWP active, ZAR inactive)
│   # - Countries (BW, ZA)
│   # - Product categories (Fruits, Vegetables, Herbs, Leafy Greens)
│   # - Products (full initial catalogue)
│   # - Product varieties (common varieties)
│   # - Units of measure (kg, tonne, crate, bunch, bag, each, g, pack)
│   # - Platform settings (commission_rate, platform_name, etc.)
│   # - Initial admin user (optional)
│
├── functions/
│   ├── send-push-notification/
│   │   └── index.ts               # Send Expo push notification
│   ├── send-whatsapp/
│   │   └── index.ts               # Send WhatsApp via Twilio/Meta API
│   ├── handle-new-order/
│   │   └── index.ts               # Triggered on new order — sends notifications
│   ├── handle-new-listing/
│   │   └── index.ts               # Triggered on new listing — notifies relevant stores
│   ├── handle-new-tender/
│   │   └── index.ts               # Triggered on new tender — notifies eligible farmers
│   ├── handle-new-review/
│   │   └── index.ts               # Triggered on new review — recalculates farmer ratings
│   ├── generate-contract-deliveries/
│   │   └── index.ts               # Generates delivery schedule when contract activated
│   └── check-expirations/
│       └── index.ts               # Cron: marks expired listings and tenders
│
└── config.toml                    # Supabase local development configuration
```

---

## 7. Naming Conventions

### Files & Folders

| Context | Convention | Example |
|---|---|---|
| Folders | kebab-case | `cropping-plans/`, `tender-offers/` |
| React components | PascalCase | `ListingCard.tsx`, `ProductPicker.tsx` |
| Hooks | camelCase with `use` prefix | `useListings.ts`, `useAuth.ts` |
| Services | kebab-case with `.service.ts` | `listing.service.ts` |
| Utility files | kebab-case or camelCase | `formatting.ts`, `date.ts` |
| Type files | kebab-case | `database.ts`, `enums.ts` |
| Expo Router pages | kebab-case | `cropping-plans/index.tsx` |
| SQL migrations | numbered prefix + snake_case | `00014_create_listings.sql` |
| Supabase functions | kebab-case folder name | `send-push-notification/` |

### Code

| Context | Convention | Example |
|---|---|---|
| React components | PascalCase | `ListingCard`, `OrderStatusBadge` |
| Functions | camelCase | `formatPrice()`, `decrementQuantity()` |
| Variables | camelCase | `currentUser`, `activeRole` |
| Constants | UPPER_SNAKE_CASE | `ORDER_STATUSES`, `MAX_LISTING_IMAGES` |
| Types/Interfaces | PascalCase | `Listing`, `OrderStatus`, `FarmerProfile` |
| Enums | PascalCase with UPPER_SNAKE values | `Role.FARMER`, `Status.ACTIVE` |
| Database columns | snake_case | `quantity_remaining`, `price_per_unit` |
| Database tables | snake_case plural | `listings`, `tender_offers` |
| API/URL paths | kebab-case | `/cropping-plans`, `/tender-offers` |
| Environment variables | UPPER_SNAKE_CASE | `EXPO_PUBLIC_SUPABASE_URL` |

### Component Organization

Each component file exports:
1. The component as default export
2. Any related types as named exports
3. Props interface named `{ComponentName}Props`

```typescript
// components/cards/ListingCard.tsx

export interface ListingCardProps {
  listing: Listing;
  onPress: (id: string) => void;
  showFarmerInfo?: boolean;
}

export default function ListingCard({ listing, onPress, showFarmerInfo = true }: ListingCardProps) {
  // ...
}
```

---

## 8. Environment Variables

### Mobile App (`apps/mobile/.env`)

```env
# Supabase
EXPO_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

# Push Notifications
EXPO_PUBLIC_EXPO_PROJECT_ID=your-expo-project-id

# WhatsApp (if calling from client — otherwise Edge Function only)
# EXPO_PUBLIC_WHATSAPP_API_URL=https://...

# App Config
EXPO_PUBLIC_DEFAULT_CURRENCY=BWP
EXPO_PUBLIC_DEFAULT_COUNTRY=BW
```

### Admin Panel (`apps/admin/.env.local`)

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key  # Server-side only — admin operations

# App Config
NEXT_PUBLIC_DEFAULT_CURRENCY=BWP
```

### Supabase Edge Functions (`supabase/.env`)

```env
# WhatsApp (Twilio)
TWILIO_ACCOUNT_SID=your-sid
TWILIO_AUTH_TOKEN=your-token
TWILIO_WHATSAPP_NUMBER=+14155238886

# Or Meta WhatsApp Business API
WHATSAPP_API_TOKEN=your-token
WHATSAPP_PHONE_ID=your-phone-id

# Expo Push Notifications
EXPO_ACCESS_TOKEN=your-expo-access-token
```

---

## 9. Package Manager & Workspace Config

### Root `package.json` (Workspace)

```json
{
  "name": "rekamoso-agrimart",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "scripts": {
    "mobile": "cd apps/mobile && npx expo start",
    "mobile:ios": "cd apps/mobile && npx expo start --ios",
    "mobile:android": "cd apps/mobile && npx expo start --android",
    "mobile:web": "cd apps/mobile && npx expo start --web",
    "admin": "cd apps/admin && npm run dev",
    "db:generate-types": "supabase gen types typescript --local > packages/supabase/types/database.types.ts",
    "db:migrate": "supabase db push",
    "db:seed": "supabase db reset",
    "db:studio": "supabase studio"
  }
}
```

---

## 10. Key Architectural Patterns

### Authentication Flow

```
App Opens
    ↓
Check Supabase session (stored in SecureStore on mobile)
    ↓
No session → Auth screens (login / register)
    ↓
Has session → Fetch user_roles
    ↓
Single role → Route to that experience (farmer or store)
Multiple roles → Show role switcher → Route to selected experience
    ↓
Farmer role + verification_status = 'pending' → Show "Awaiting Approval" screen
Farmer role + verification_status = 'approved' → Full farmer experience
Store role → Full store experience
```

### Data Fetching Pattern

```
Screen mounts
    ↓
Hook calls service function
    ↓
Service function calls Supabase query (from packages/supabase/queries/)
    ↓
Data returned → hook updates state → screen renders
    ↓
Real-time subscription listens for changes → auto-refreshes
```

### Offline Queue Pattern

```
User performs action (e.g., create listing)
    ↓
Check network status (useNetworkStatus hook)
    ↓
Online → Send to Supabase immediately
Offline → Save to local queue (MMKV/AsyncStorage)
    ↓
Show "Pending sync" badge on the item
    ↓
Network restored → Process queue in order
    ↓
Success → Remove from queue, update UI
Failure → Keep in queue, show error, retry later
```

### Role-Based Navigation

```
(auth)/          → Visible when NOT authenticated
(farmer)/        → Visible when authenticated + active role is 'farmer'
(store)/         → Visible when authenticated + active role is 'store'
role-switcher    → Visible when user has multiple roles
```

Expo Router layout groups `(auth)`, `(farmer)`, and `(store)` are conditionally rendered based on auth state and active role. This is handled in the root `_layout.tsx`.

---

## 11. Development Workflow

### Initial Setup

```bash
# 1. Clone repo
git clone <repo-url>
cd rekamoso-agrimart

# 2. Install dependencies
npm install

# 3. Set up Supabase locally
supabase init
supabase start

# 4. Run migrations
supabase db push

# 5. Seed the database
supabase db reset  # Runs migrations + seed.sql

# 6. Generate TypeScript types
npm run db:generate-types

# 7. Set up environment variables
cp apps/mobile/.env.example apps/mobile/.env
cp apps/admin/.env.example apps/admin/.env.local
# Fill in your Supabase URL and keys

# 8. Start development
npm run mobile    # Expo app
npm run admin     # Admin panel (separate terminal)
```

### Build Order (Recommended)

Phase 1 development should follow this order:

```
1. Supabase setup (migrations, seed data, RLS policies)
2. Shared types and constants (packages/shared)
3. Supabase queries package (packages/supabase)
4. Auth flow (login, register, OTP, role routing)
5. Farmer registration + admin approval flow
6. Product catalogue + product picker components
7. Listings (create, browse, order from listing)
8. Order management (status flow, delivery confirmation)
9. Cropping plans
10. Tenders (create, browse, submit offer, accept)
11. Contracts (create, accept, delivery tracking)
12. Reviews and ratings
13. Notifications (push + WhatsApp)
14. Admin panel (farmer management, catalogue, transactions)
15. Polish (offline queue, edge cases, error handling)
```

---

## 12. Git Branching Strategy

```
main                    # Production-ready code
├── develop             # Integration branch
│   ├── feature/auth    # Feature branches
│   ├── feature/listings
│   ├── feature/tenders
│   ├── feature/contracts
│   ├── feature/orders
│   ├── feature/notifications
│   ├── feature/admin-panel
│   └── fix/listing-quantity-bug  # Bug fixes
```

### Commit Message Format

```
type(scope): description

feat(listings): add create listing form with product picker
fix(orders): use atomic decrement for listing quantity
chore(db): add migration for currencies table
docs(readme): update setup instructions
style(theme): update brand colors
```

Types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `test`

---

*Document version: 1.0*
*Last updated: February 2025*
*Platform: ReKamoso AgriMart*
*Companion to: PROJECT_BRIEF.md and DATABASE_SCHEMA.md*
