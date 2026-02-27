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
