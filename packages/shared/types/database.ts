import type {
  UserRole,
  VerificationStatus,
  ListingStatus,
  OrderStatus,
  PaymentStatus,
  PaymentMethod,
  OrderSource,
  TenderStatus,
  TenderOfferStatus,
  ContractStatus,
  ContractDeliveryStatus,
  DeliveryOption,
  DeliveryMethod,
  GrowingStatus,
  DeliveryFrequency,
  StoreType,
  UnitContext,
  NotificationType,
  NotificationChannel,
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
  farm_size: string | null;
  farm_size_unit: string | null;
  id_number: string | null;
  bio: string | null;
  verification_status: VerificationStatus;
  rejection_reason: string | null;
  verified_at: string | null;
  verified_by: string | null;
  avg_overall_rating: number;
  avg_quality_rating: number;
  avg_reliability_rating: number;
  total_reviews: number;
  total_transactions: number;
  contract_fulfillment_rate: number;
  created_at: string;
  updated_at: string;
}

export interface FarmImage {
  id: string;
  farmer_id: string;
  image_url: string;
  is_primary: boolean;
  created_at: string;
}

export interface Store {
  id: string;
  profile_id: string;
  business_name: string;
  store_type: StoreType;
  location_lat: number | null;
  location_lng: number | null;
  address: string | null;
  country_id: string | null;
  contact_phone: string | null;
  contact_email: string | null;
  bio: string | null;
  logo_url: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface AdminUser {
  id: string;
  profile_id: string;
  permissions: string;
  created_at: string;
}

export interface ProductCategory {
  id: string;
  name: string;
  description: string | null;
  icon_url: string | null;
  sort_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Product {
  id: string;
  category_id: string;
  name: string;
  description: string | null;
  image_url: string | null;
  sort_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface ProductVariety {
  id: string;
  product_id: string;
  name: string;
  description: string | null;
  is_active: boolean;
  created_at: string;
}

export interface ProductRequest {
  id: string;
  farmer_id: string;
  product_name: string;
  suggested_category_id: string | null;
  description: string | null;
  status: string;
  admin_notes: string | null;
  reviewed_by: string | null;
  reviewed_at: string | null;
  created_product_id: string | null;
  created_at: string;
}

export interface UnitOfMeasure {
  id: string;
  name: string;
  abbreviation: string;
  context: UnitContext;
  sort_order: number;
  is_active: boolean;
  created_at: string;
}

export interface FarmerProduct {
  id: string;
  farmer_id: string;
  product_id: string;
  created_at: string;
}

export interface Listing {
  id: string;
  farmer_id: string;
  product_id: string;
  variety_id: string | null;
  title: string | null;
  description: string | null;
  quantity: number;
  quantity_remaining: number;
  unit_id: string;
  price_per_unit: number;
  currency_code: string;
  quality_grade: string | null;
  available_from: string;
  available_until: string;
  delivery_options: DeliveryOption;
  status: ListingStatus;
  created_at: string;
  updated_at: string;
}

export interface ListingImage {
  id: string;
  listing_id: string;
  image_url: string;
  sort_order: number;
  created_at: string;
}

export interface CroppingPlan {
  id: string;
  farmer_id: string;
  product_id: string;
  variety_id: string | null;
  date_planted: string;
  expected_harvest_date: string;
  estimated_yield: number | null;
  yield_unit_id: string | null;
  actual_yield: number | null;
  growing_status: GrowingStatus;
  is_contracted: boolean;
  contract_id: string | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
}

export interface Tender {
  id: string;
  store_id: string;
  product_id: string;
  variety_id: string | null;
  quantity_needed: number;
  unit_id: string;
  min_price: number | null;
  max_price: number | null;
  currency_code: string;
  date_needed_by: string;
  quality_requirements: string | null;
  delivery_preference: DeliveryOption;
  quantity_fulfilled: number;
  status: TenderStatus;
  expires_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface TenderOffer {
  id: string;
  tender_id: string;
  farmer_id: string;
  quantity_offered: number;
  price_per_unit: number;
  currency_code: string;
  delivery_date: string;
  delivery_method: DeliveryMethod;
  notes: string | null;
  status: TenderOfferStatus;
  responded_at: string | null;
  created_at: string;
}

export interface Contract {
  id: string;
  store_id: string;
  farmer_id: string | null;
  product_id: string;
  variety_id: string | null;
  quantity_per_delivery: number;
  unit_id: string;
  price_per_unit: number;
  currency_code: string;
  delivery_frequency: DeliveryFrequency;
  custom_frequency_days: number | null;
  quality_standards: string | null;
  payment_terms: string | null;
  start_date: string;
  end_date: string;
  total_contracted_qty: number | null;
  total_delivered_qty: number;
  fulfillment_rate: number;
  status: ContractStatus;
  is_public: boolean;
  created_at: string;
  updated_at: string;
}

export interface ContractDelivery {
  id: string;
  contract_id: string;
  expected_date: string;
  actual_date: string | null;
  expected_quantity: number;
  actual_quantity: number | null;
  status: ContractDeliveryStatus;
  farmer_notes: string | null;
  store_notes: string | null;
  quality_rating: number | null;
  order_id: string | null;
  created_at: string;
  updated_at: string;
}

export interface Order {
  id: string;
  order_number: string;
  store_id: string;
  farmer_id: string;
  source: OrderSource;
  listing_id: string | null;
  tender_offer_id: string | null;
  contract_delivery_id: string | null;
  delivery_method: DeliveryMethod;
  delivery_date: string | null;
  delivery_address: string | null;
  pickup_address: string | null;
  subtotal: number;
  currency_code: string;
  commission_rate: number;
  commission_amount: number;
  status: OrderStatus;
  payment_status: PaymentStatus;
  payment_method: PaymentMethod | null;
  actual_qty_received: number | null;
  store_notes: string | null;
  farmer_notes: string | null;
  created_at: string;
  updated_at: string;
}

export interface OrderItem {
  id: string;
  order_id: string;
  product_id: string;
  variety_id: string | null;
  quantity: number;
  unit_id: string;
  price_per_unit: number;
  currency_code: string;
  line_total: number;
  actual_qty_received: number | null;
  quality_notes: string | null;
  created_at: string;
}

export interface Review {
  id: string;
  order_id: string;
  store_id: string;
  farmer_id: string;
  overall_rating: number;
  quality_rating: number;
  reliability_rating: number;
  comment: string | null;
  created_at: string;
}

export interface Notification {
  id: string;
  recipient_id: string;
  type: NotificationType;
  title: string;
  body: string;
  data: Record<string, unknown> | null;
  channel: NotificationChannel;
  is_read: boolean;
  push_sent: boolean;
  whatsapp_sent: boolean;
  created_at: string;
}

export interface PlatformSetting {
  id: string;
  key: string;
  value: string;
  description: string | null;
  updated_at: string;
  updated_by: string | null;
}

export interface Currency {
  id: string;
  code: string;
  name: string;
  symbol: string;
  decimal_precision: number;
  is_active: boolean;
  created_at: string;
}

export interface Country {
  id: string;
  code: string;
  name: string;
  currency_id: string;
  is_active: boolean;
  created_at: string;
}
