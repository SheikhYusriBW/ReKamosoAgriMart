# CURSOR PROMPT 3 — Shared Types, Constants, Utilities & Supabase Queries Package

> Paste everything below this line into Cursor.

---

## Context

Read `ARCHITECTURE.md` and `docs/DATABASE_SCHEMA.md`. The database is now live with all 26 tables. This prompt builds the data layer that sits between the database and the UI — types, constants, utilities, and query functions that both the mobile app and admin panel will import.

Reference `docs/PROJECT_STRUCTURE.md` Sections 4 and 5 for the exact folder layout.

## Task

Build out `packages/shared/` and `packages/supabase/` completely. These are the two shared packages that both `apps/mobile` and `apps/admin` will depend on.

---

### Part 1: Generate Supabase TypeScript Types

First, generate the auto-typed database types from Supabase. Create a script or add instructions in a comment, but also create a placeholder type file.

Create `packages/supabase/types/database.types.ts`:
- Run `supabase gen types typescript --local > packages/supabase/types/database.types.ts` to generate this file from the local database
- If the command can't be run directly, create the file manually with types matching ALL 26 tables from `docs/DATABASE_SCHEMA.md` exactly — every column, every type, every nullable field
- Export the `Database` type that maps to all tables in the `public` schema
- This file should follow Supabase's generated type format:

```typescript
export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: { /* all columns with types */ }
        Insert: { /* columns for insert — omit auto-generated fields */ }
        Update: { /* all columns optional for partial updates */ }
      }
      // ... all 26 tables
    }
    Functions: {
      decrement_listing_quantity: { /* args and return type */ }
      increment_tender_fulfillment: { /* args and return type */ }
      update_contract_delivery_totals: { /* args and return type */ }
      assign_user_role: { /* args and return type */ }
      is_admin: { /* args and return type */ }
      has_role: { /* args and return type */ }
    }
    Enums: { /* if any */ }
  }
}
```

---

### Part 2: Supabase Client (`packages/supabase/`)

**`packages/supabase/client.ts`** — Update the existing client file to be properly typed:

```typescript
import { createClient } from '@supabase/supabase-js';
import { Database } from './types/database.types';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey);
```

Also create `packages/supabase/admin-client.ts` for the admin panel (uses service_role key):

```typescript
import { createClient } from '@supabase/supabase-js';
import { Database } from './types/database.types';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

export const supabaseAdmin = createClient<Database>(supabaseUrl, supabaseServiceKey);
```

---

### Part 3: Shared Types (`packages/shared/types/`)

Create TypeScript types that the app uses at the UI level. These are friendlier versions of the database types, plus API-specific types.

**`packages/shared/types/enums.ts`** — All enum/union types used across the app:

```typescript
export type UserRole = 'farmer' | 'store' | 'admin';

export type VerificationStatus = 'pending' | 'approved' | 'rejected' | 'suspended';

export type ListingStatus = 'draft' | 'active' | 'sold' | 'expired' | 'cancelled';

export type OrderStatus = 'new' | 'accepted' | 'preparing' | 'ready' | 'in_transit' | 'delivered' | 'confirmed' | 'cancelled';

export type PaymentStatus = 'unpaid' | 'paid' | 'confirmed';

export type PaymentMethod = 'cash' | 'eft' | 'other';

export type OrderSource = 'spot' | 'tender' | 'contract';

export type TenderStatus = 'active' | 'fulfilled' | 'expired' | 'cancelled';

export type TenderOfferStatus = 'pending' | 'accepted' | 'declined';

export type ContractStatus = 'open' | 'accepted' | 'active' | 'completed' | 'cancelled';

export type ContractDeliveryStatus = 'upcoming' | 'due' | 'delivered' | 'confirmed' | 'missed';

export type DeliveryOption = 'farmer_delivers' | 'store_collects' | 'either';

export type DeliveryMethod = 'farmer_delivers' | 'store_collects' | 'third_party';

export type GrowingStatus = 'planted' | 'growing' | 'approaching_harvest' | 'ready' | 'harvested';

export type DeliveryFrequency = 'weekly' | 'biweekly' | 'monthly' | 'custom';

export type StoreType = 'grocery' | 'depo' | 'restaurant' | 'hotel' | 'other';

export type UnitContext = 'farmer_to_store' | 'store_to_consumer' | 'both';

export type NotificationType =
  | 'order_placed'
  | 'order_accepted'
  | 'order_status_changed'
  | 'order_confirmed'
  | 'order_cancelled'
  | 'tender_created'
  | 'tender_offer_received'
  | 'tender_offer_accepted'
  | 'tender_offer_declined'
  | 'contract_offer_received'
  | 'contract_accepted'
  | 'contract_delivery_reminder'
  | 'contract_delivery_confirmed'
  | 'new_listing'
  | 'listing_match'
  | 'review_received'
  | 'farmer_approved'
  | 'farmer_rejected'
  | 'product_request_approved'
  | 'product_request_rejected';

export type NotificationChannel = 'push' | 'whatsapp' | 'both';
```

**`packages/shared/types/database.ts`** — App-level types for each entity. Create an interface for every table that mirrors the database row but uses the enum types above. Include all 26 tables. Here are the key ones (create ALL of them):

```typescript
import type {
  UserRole, VerificationStatus, ListingStatus, OrderStatus,
  PaymentStatus, PaymentMethod, OrderSource, TenderStatus,
  TenderOfferStatus, ContractStatus, ContractDeliveryStatus,
  DeliveryOption, DeliveryMethod, GrowingStatus, DeliveryFrequency,
  StoreType, UnitContext, NotificationType, NotificationChannel
} from './enums';

export interface Profile {
  id: string;
  phone: string;
  email: string | null;
  full_name: string;
  avatar_url: string | null;
  created_at: string;
  updated_at: string;
}

export interface UserRoleRecord {
  id: string;
  profile_id: string;
  role: UserRole;
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
  farm_size: number | null;
  farm_size_unit: string | null;
  bio: string | null;
  id_number: string | null;
  verification_status: VerificationStatus;
  verified_at: string | null;
  verified_by: string | null;
  rejection_reason: string | null;
  avg_overall_rating: number;
  avg_quality_rating: number;
  avg_reliability_rating: number;
  total_reviews: number;
  total_transactions: number;
  contract_fulfillment_rate: number;
  created_at: string;
  updated_at: string;
}

// Create interfaces for ALL remaining tables:
// FarmImage, Store, AdminUser, ProductCategory, Product, ProductVariety,
// ProductRequest, UnitOfMeasure, FarmerProduct, Listing, ListingImage,
// CroppingPlan, Tender, TenderOffer, Contract, ContractDelivery,
// Order, OrderItem, Review, Notification, PlatformSetting, Currency, Country
```

Complete ALL 26 table interfaces following the exact columns from `docs/DATABASE_SCHEMA.md`.

**`packages/shared/types/api.ts`** — Types for common data patterns used in the UI:

```typescript
import type { Listing, Farmer, Profile, Product, ProductVariety, UnitOfMeasure, Store, Currency } from './database';

// Listing with all joined data for display
export interface ListingWithDetails extends Listing {
  product: Product;
  variety: ProductVariety | null;
  unit: UnitOfMeasure;
  farmer: Farmer & { profile: Profile };
  images: string[]; // array of image URLs
  currency: Currency;
}

// Tender with joined data
export interface TenderWithDetails extends Tender {
  product: Product;
  variety: ProductVariety | null;
  unit: UnitOfMeasure;
  store: Store & { profile: Profile };
  currency: Currency;
  offers_count: number;
}

// Order with full details
export interface OrderWithDetails extends Order {
  items: OrderItemWithProduct[];
  farmer: Farmer & { profile: Profile };
  store: Store & { profile: Profile };
  review: Review | null;
}

// Order item with product info
export interface OrderItemWithProduct extends OrderItem {
  product: Product;
  variety: ProductVariety | null;
  unit: UnitOfMeasure;
}

// Contract with full details
export interface ContractWithDetails extends Contract {
  product: Product;
  variety: ProductVariety | null;
  unit: UnitOfMeasure;
  farmer: (Farmer & { profile: Profile }) | null;
  store: Store & { profile: Profile };
  currency: Currency;
  deliveries: ContractDelivery[];
  next_delivery: ContractDelivery | null;
}

// Tender offer with farmer info
export interface TenderOfferWithFarmer extends TenderOffer {
  farmer: Farmer & { profile: Profile };
}

// Cropping plan with details
export interface CroppingPlanWithDetails extends CroppingPlan {
  product: Product;
  variety: ProductVariety | null;
  unit: UnitOfMeasure;
  contract: Contract | null;
}

// Farmer public profile (what stores see)
export interface FarmerPublicProfile extends Farmer {
  profile: Profile;
  products: Product[];
  active_listings_count: number;
}

// Dashboard stat types
export interface FarmerDashboardStats {
  active_listings: number;
  open_orders: number;
  active_contracts: number;
  avg_rating: number;
  next_harvest: CroppingPlanWithDetails | null;
  next_delivery: ContractDelivery | null;
}

export interface StoreDashboardStats {
  new_listings: number;
  open_orders: number;
  active_contracts: number;
  active_tenders: number;
  next_delivery: ContractDelivery | null;
}
```

**`packages/shared/types/index.ts`** — Re-export everything:

```typescript
export * from './enums';
export * from './database';
export * from './api';
```

---

### Part 4: Shared Constants (`packages/shared/constants/`)

Create a constant file for every status type. Each file exports the values, labels, and colors for use in badges and filters.

**`packages/shared/constants/roles.ts`:**
```typescript
export const ROLES = {
  FARMER: 'farmer',
  STORE: 'store',
  ADMIN: 'admin',
} as const;

export const ROLE_LABELS: Record<string, string> = {
  farmer: 'Farmer',
  store: 'Store',
  admin: 'Admin',
};
```

Create similar files for:

**`order-statuses.ts`** — ORDER_STATUSES object, ORDER_STATUS_LABELS, ORDER_STATUS_COLORS (use hex colors: green for confirmed, red for cancelled, orange for in_transit, blue for new, etc.)

**`listing-statuses.ts`** — LISTING_STATUSES, LISTING_STATUS_LABELS, LISTING_STATUS_COLORS

**`tender-statuses.ts`** — TENDER_STATUSES, TENDER_STATUS_LABELS, TENDER_STATUS_COLORS

**`tender-offer-statuses.ts`** — TENDER_OFFER_STATUSES, labels, colors

**`contract-statuses.ts`** — CONTRACT_STATUSES, labels, colors

**`contract-delivery-statuses.ts`** — CONTRACT_DELIVERY_STATUSES, labels, colors

**`verification-statuses.ts`** — VERIFICATION_STATUSES, labels, colors

**`growing-statuses.ts`** — GROWING_STATUSES, labels, colors

**`delivery-methods.ts`** — DELIVERY_METHODS, DELIVERY_METHOD_LABELS

**`delivery-options.ts`** — DELIVERY_OPTIONS, DELIVERY_OPTION_LABELS

**`payment-statuses.ts`** — PAYMENT_STATUSES, labels, colors

**`payment-methods.ts`** — PAYMENT_METHODS, labels

**`notification-types.ts`** — NOTIFICATION_TYPES object with all notification type constants, labels, and icons (use string icon names that can map to an icon library later)

**`store-types.ts`** — STORE_TYPES, STORE_TYPE_LABELS

**`app.ts`** — App-wide constants:
```typescript
export const APP_NAME = 'ReKamoso AgriMart';
export const DEFAULT_CURRENCY = 'BWP';
export const DEFAULT_COUNTRY = 'BW';
export const MAX_LISTING_IMAGES = 5;
export const MAX_FARM_IMAGES = 10;
export const OTP_LENGTH = 6;
export const OTP_RESEND_SECONDS = 60;
export const DEFAULT_PAGE_SIZE = 20;
export const MIN_RATING = 1;
export const MAX_RATING = 5;
```

**`packages/shared/constants/index.ts`** — Re-export everything.

---

### Part 5: Shared Utilities (`packages/shared/utils/`)

**`packages/shared/utils/currency.ts`:**
```typescript
import type { Currency } from '../types';

/**
 * Format a price with currency symbol.
 * formatPrice(50, { symbol: 'P', decimal_precision: 2 }) → "P50.00"
 * formatPrice(1250.5, { symbol: 'R', decimal_precision: 2 }) → "R1,250.50"
 */
export function formatPrice(amount: number, currency: { symbol: string; decimal_precision: number }): string {
  const formatted = amount.toLocaleString('en-US', {
    minimumFractionDigits: currency.decimal_precision,
    maximumFractionDigits: currency.decimal_precision,
  });
  return `${currency.symbol}${formatted}`;
}

/**
 * Shorthand when you have the full currency object.
 */
export function formatPriceWithCurrency(amount: number, currency: Currency): string {
  return formatPrice(amount, {
    symbol: currency.symbol,
    decimal_precision: currency.decimal_precision,
  });
}

/**
 * Default BWP formatting.
 */
export function formatBWP(amount: number): string {
  return formatPrice(amount, { symbol: 'P', decimal_precision: 2 });
}
```

**`packages/shared/utils/date.ts`:**
```typescript
/**
 * Format a date string to readable format.
 * formatDate('2025-03-15T10:30:00Z') → "15 Mar 2025"
 */
export function formatDate(dateString: string): string {
  const date = new Date(dateString);
  return date.toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  });
}

/**
 * Format to relative time: "2 hours ago", "3 days ago", "just now"
 */
export function timeAgo(dateString: string): string {
  const now = new Date();
  const date = new Date(dateString);
  const seconds = Math.floor((now.getTime() - date.getTime()) / 1000);

  if (seconds < 60) return 'just now';
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d ago`;
  const weeks = Math.floor(days / 7);
  if (weeks < 4) return `${weeks}w ago`;
  return formatDate(dateString);
}

/**
 * Format date range: "15 Mar — 20 Apr 2025"
 */
export function formatDateRange(from: string, to: string): string {
  const fromDate = new Date(from);
  const toDate = new Date(to);
  const fromStr = fromDate.toLocaleDateString('en-GB', { day: 'numeric', month: 'short' });
  const toStr = toDate.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
  return `${fromStr} — ${toStr}`;
}

/**
 * Days remaining until a date. Returns negative if past.
 */
export function daysUntil(dateString: string): number {
  const now = new Date();
  const target = new Date(dateString);
  const diff = target.getTime() - now.getTime();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
}

/**
 * Check if a date is in the past.
 */
export function isPast(dateString: string): boolean {
  return new Date(dateString) < new Date();
}
```

**`packages/shared/utils/quantity.ts`:**
```typescript
import type { UnitOfMeasure } from '../types';

/**
 * Format quantity with unit abbreviation.
 * formatQuantity(500, { abbreviation: 'kg' }) → "500 kg"
 * formatQuantity(1.5, { abbreviation: 't' }) → "1.5 t"
 */
export function formatQuantity(amount: number, unit: { abbreviation: string }): string {
  // Remove trailing zeros for clean display
  const formatted = parseFloat(amount.toFixed(2)).toString();
  return `${formatted} ${unit.abbreviation}`;
}

/**
 * Format quantity remaining vs total: "350 / 500 kg"
 */
export function formatQuantityProgress(remaining: number, total: number, unit: { abbreviation: string }): string {
  const r = parseFloat(remaining.toFixed(2));
  const t = parseFloat(total.toFixed(2));
  return `${r} / ${t} ${unit.abbreviation}`;
}

/**
 * Calculate percentage remaining: 70%
 */
export function quantityPercentage(remaining: number, total: number): number {
  if (total <= 0) return 0;
  return Math.round((remaining / total) * 100);
}
```

**`packages/shared/utils/validation.ts`:**
```typescript
/**
 * Validate Botswana phone number (+267 followed by 7 or 8 digits).
 * Also accepts South African numbers (+27 followed by 9 digits).
 */
export function isValidPhone(phone: string): boolean {
  const cleaned = phone.replace(/[\s\-\(\)]/g, '');
  // Botswana: +267XXXXXXX (7-8 digits after code)
  // South Africa: +27XXXXXXXXX (9 digits after code)
  return /^\+267\d{7,8}$/.test(cleaned) || /^\+27\d{9}$/.test(cleaned);
}

/**
 * Validate email format.
 */
export function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

/**
 * Validate that a value is a positive number.
 */
export function isPositiveNumber(value: unknown): boolean {
  const num = Number(value);
  return !isNaN(num) && num > 0;
}

/**
 * Validate that end date is after start date.
 */
export function isDateAfter(startDate: string, endDate: string): boolean {
  return new Date(endDate) > new Date(startDate);
}

/**
 * Validate that a date is in the future.
 */
export function isFutureDate(dateString: string): boolean {
  return new Date(dateString) > new Date();
}

/**
 * Validate rating is between 1 and 5.
 */
export function isValidRating(rating: number): boolean {
  return Number.isInteger(rating) && rating >= 1 && rating <= 5;
}

/**
 * Validate OTP is 6 digits.
 */
export function isValidOTP(otp: string): boolean {
  return /^\d{6}$/.test(otp);
}
```

**`packages/shared/utils/index.ts`** — Re-export everything.

**`packages/shared/index.ts`** — Re-export all types, constants, and utils:
```typescript
export * from './types';
export * from './constants';
export * from './utils';
```

---

### Part 6: Supabase Query Functions (`packages/supabase/queries/`)

Create query files for every major entity. Each file exports typed functions that call Supabase. Use the `Database` type for full type safety.

**`packages/supabase/queries/profiles.ts`:**
- `getProfile(userId: string)` — fetch profile by ID
- `updateProfile(userId: string, updates: Partial<Profile>)` — update profile fields
- `uploadAvatar(userId: string, file: File | Blob)` — upload to avatars bucket, update avatar_url

**`packages/supabase/queries/auth.ts`:**
- `sendOTP(phone: string)` — trigger Supabase phone OTP
- `verifyOTP(phone: string, token: string)` — verify OTP and get session
- `getSession()` — get current session
- `signOut()` — sign out
- `getUserRoles(profileId: string)` — fetch user's roles from user_roles table

**`packages/supabase/queries/farmers.ts`:**
- `getFarmer(farmerId: string)` — fetch single farmer with profile
- `getFarmerByProfileId(profileId: string)` — fetch farmer by their profile ID
- `createFarmer(data: InsertFarmer)` — create farmer record
- `updateFarmer(farmerId: string, updates: Partial<Farmer>)` — update farmer
- `getApprovedFarmers(filters?: { productId?: string, search?: string })` — list approved farmers with optional filters
- `getPendingFarmers()` — admin: list pending applications
- `approveFarmer(farmerId: string, adminId: string)` — admin: approve
- `rejectFarmer(farmerId: string, reason: string)` — admin: reject
- `suspendFarmer(farmerId: string)` — admin: suspend
- `getFarmerProducts(farmerId: string)` — get products a farmer grows
- `setFarmerProducts(farmerId: string, productIds: string[])` — replace farmer's product list
- `getFarmerStats(farmerId: string)` — fetch dashboard stat counts

**`packages/supabase/queries/stores.ts`:**
- `getStore(storeId: string)` — fetch single store with profile
- `getStoreByProfileId(profileId: string)` — fetch store by profile ID
- `createStore(data: InsertStore)` — create store record
- `updateStore(storeId: string, updates: Partial<Store>)` — update store
- `getAllStores()` — admin: list all stores
- `getStoreStats(storeId: string)` — dashboard stat counts

**`packages/supabase/queries/products.ts`:**
- `getCategories()` — all active categories
- `getProducts(categoryId?: string)` — products, optionally filtered by category
- `getProductVarieties(productId: string)` — varieties for a product
- `getProductById(productId: string)` — single product with category and varieties
- `createProduct(data: InsertProduct)` — admin: add product
- `updateProduct(productId: string, updates: Partial<Product>)` — admin: update
- `createProductRequest(data: InsertProductRequest)` — farmer: request new product
- `getPendingProductRequests()` — admin: list pending requests
- `approveProductRequest(requestId: string, productData: InsertProduct)` — admin: approve and create product
- `rejectProductRequest(requestId: string, reason: string)` — admin: reject

**`packages/supabase/queries/units.ts`:**
- `getUnits(context?: UnitContext)` — get units, optionally filtered by context

**`packages/supabase/queries/currencies.ts`:**
- `getCurrencies(activeOnly?: boolean)` — list currencies
- `getCountries(activeOnly?: boolean)` — list countries with currency
- `getCurrencyByCode(code: string)` — single currency

**`packages/supabase/queries/listings.ts`:**
- `createListing(data: InsertListing)` — create listing
- `updateListing(listingId: string, updates: Partial<Listing>)` — update listing
- `deleteListing(listingId: string)` — delete draft listing
- `getMyListings(farmerId: string, status?: ListingStatus)` — farmer's listings with filters
- `getActiveListings(filters?: { productId?: string, categoryId?: string, search?: string, sortBy?: string })` — browse listings for stores
- `getListingById(listingId: string)` — single listing with all joins (product, variety, unit, farmer, images, currency)
- `decrementListingQuantity(listingId: string, quantity: number)` — **MUST call the RPC function, never direct update**
- `uploadListingImage(listingId: string, file: File | Blob)` — upload to listing-images bucket
- `deleteListingImage(imageId: string)` — delete image

**`packages/supabase/queries/cropping-plans.ts`:**
- `createCroppingPlan(data: InsertCroppingPlan)` — create plan
- `updateCroppingPlan(planId: string, updates: Partial<CroppingPlan>)` — update plan
- `getMyCroppingPlans(farmerId: string, status?: GrowingStatus)` — farmer's plans
- `getAllCroppingPlans(filters?: { productId?: string })` — store: browse all plans
- `getCroppingPlanById(planId: string)` — single plan with joins

**`packages/supabase/queries/tenders.ts`:**
- `createTender(data: InsertTender)` — store creates tender
- `updateTender(tenderId: string, updates: Partial<Tender>)` — update tender
- `getMyTenders(storeId: string, status?: TenderStatus)` — store's tenders
- `getActiveTenders(filters?: { productId?: string })` — farmer: browse active tenders
- `getTenderById(tenderId: string)` — single tender with all joins
- `incrementTenderFulfillment(tenderId: string, quantity: number)` — **MUST call RPC function**

**`packages/supabase/queries/tender-offers.ts`:**
- `createTenderOffer(data: InsertTenderOffer)` — farmer submits offer
- `withdrawTenderOffer(offerId: string)` — farmer withdraws
- `getOffersForTender(tenderId: string)` — store: all offers on their tender with farmer info
- `getMyTenderOffers(farmerId: string)` — farmer: all my offers
- `acceptTenderOffer(offerId: string)` — store accepts → creates order
- `declineTenderOffer(offerId: string)` — store declines

**`packages/supabase/queries/contracts.ts`:**
- `createContract(data: InsertContract)` — store creates contract
- `updateContract(contractId: string, updates: Partial<Contract>)` — update contract
- `getMyContracts(userId: string, role: 'farmer' | 'store', status?: ContractStatus)` — user's contracts by role
- `getContractById(contractId: string)` — single contract with all joins and deliveries
- `acceptContract(contractId: string, farmerId: string)` — farmer accepts
- `cancelContract(contractId: string)` — cancel contract
- `getOpenContracts(filters?: { productId?: string })` — farmer: browse public offers

**`packages/supabase/queries/contract-deliveries.ts`:**
- `getDeliveriesForContract(contractId: string)` — all deliveries for a contract
- `logDelivery(deliveryId: string, data: { actual_date: string, actual_quantity: number, farmer_notes?: string })` — farmer logs delivery
- `confirmDelivery(deliveryId: string, data: { quality_rating?: number, store_notes?: string })` — store confirms
- `updateContractDeliveryTotals(contractId: string, quantity: number)` — **MUST call RPC function**

**`packages/supabase/queries/orders.ts`:**
- `createOrder(data: InsertOrder, items: InsertOrderItem[])` — create order with items (transaction: create order + items + decrement listing)
- `updateOrderStatus(orderId: string, status: OrderStatus)` — update status
- `updatePaymentStatus(orderId: string, status: PaymentStatus)` — update payment
- `confirmOrderReceipt(orderId: string, data: { actual_qty_received?: number, store_notes?: string })` — store confirms
- `getMyOrders(userId: string, role: 'farmer' | 'store', filters?: { status?: OrderStatus, source?: OrderSource })` — user's orders
- `getOrderById(orderId: string)` — single order with all joins
- `getAllOrders(filters?: object)` — admin: all orders

**`packages/supabase/queries/reviews.ts`:**
- `createReview(data: InsertReview)` — store creates review (triggers rating recalculation)
- `getReviewsForFarmer(farmerId: string)` — all reviews for a farmer
- `getReviewForOrder(orderId: string)` — single review for an order

**`packages/supabase/queries/notifications.ts`:**
- `getMyNotifications(userId: string, limit?: number)` — get notifications, newest first
- `getUnreadCount(userId: string)` — count unread
- `markAsRead(notificationId: string)` — mark single as read
- `markAllAsRead(userId: string)` — mark all as read
- `createNotification(data: InsertNotification)` — system: create notification

**`packages/supabase/queries/platform-settings.ts`:**
- `getSettings()` — get all platform settings as key-value object
- `getSetting(key: string)` — get single setting
- `updateSetting(key: string, value: string, adminId: string)` — admin: update setting

---

### Part 7: Real-time Subscription Helpers (`packages/supabase/realtime/`)

**`packages/supabase/realtime/notifications.ts`:**
- `subscribeToNotifications(userId: string, callback: (notification) => void)` — subscribe to new notifications for user
- Returns the subscription channel for cleanup

**`packages/supabase/realtime/orders.ts`:**
- `subscribeToOrdersAsFarmer(farmerId: string, callback)` — farmer: new orders
- `subscribeToOrderStatusChanges(orderId: string, callback)` — either: status changes on specific order

**`packages/supabase/realtime/listings.ts`:**
- `subscribeToNewListings(callback)` — store: new active listings

**`packages/supabase/realtime/tenders.ts`:**
- `subscribeToNewTenders(callback)` — farmer: new active tenders
- `subscribeToTenderOffers(tenderId: string, callback)` — store: new offers on their tender

---

### Part 8: Storage Helpers (`packages/supabase/storage/upload.ts`)

```typescript
- `uploadFile(bucket: string, path: string, file: File | Blob)` — generic upload
- `getPublicUrl(bucket: string, path: string)` — get public URL
- `deleteFile(bucket: string, path: string)` — delete file
- `uploadAvatar(userId: string, file: File | Blob)` → returns public URL
- `uploadFarmImage(farmerId: string, file: File | Blob)` → returns public URL
- `uploadListingImage(listingId: string, file: File | Blob)` → returns public URL
- `uploadStoreLogo(storeId: string, file: File | Blob)` → returns public URL
```

---

### Part 9: Package Exports

**`packages/supabase/index.ts`** — Re-export client, admin client, all queries, realtime, and storage:

```typescript
export { supabase } from './client';
export { supabaseAdmin } from './admin-client';
export * from './types/database.types';
export * from './queries';
export * from './realtime';
export * from './storage/upload';
```

Create `packages/supabase/queries/index.ts` that re-exports all query files.
Create `packages/supabase/realtime/index.ts` that re-exports all realtime files.

---

## Requirements

- Every function must be fully typed using the Database types and shared types
- Every function must handle errors: return `{ data, error }` pattern matching Supabase client
- Query functions that JOIN related tables should use Supabase's `.select('*, product:products(*), ...')` syntax
- Functions that call RPC (atomic operations) must use `supabase.rpc('function_name', { args })` — NEVER direct column updates for quantity_remaining, quantity_fulfilled, or total_delivered_qty
- Include JSDoc comments on every exported function describing what it does
- Pagination: list functions should accept `page` and `pageSize` parameters (default 20)
- Sorting: list functions should accept `sortBy` and `sortOrder` parameters where relevant

## Do NOT

- Do not create any UI components or screens
- Do not modify the migration files from Prompt 2
- Do not add dependencies that aren't already installed
- Do not create hooks (those come in Prompt 4 inside the Expo app)

## Expected Result

After this task:
1. `packages/shared/` exports all types, constants, and utilities
2. `packages/supabase/` exports the client, all query functions, realtime helpers, and storage helpers
3. Both packages compile without errors
4. Every database table has corresponding types and query functions
5. Both `apps/mobile` and `apps/admin` can import from `@rekamoso/shared` and `@rekamoso/supabase`
