import type {
  Listing,
  Farmer,
  Profile,
  Product,
  ProductVariety,
  UnitOfMeasure,
  Store,
  Currency,
  Tender,
  TenderOffer,
  Contract,
  ContractDelivery,
  Order,
  OrderItem,
  Review,
  CroppingPlan,
} from './database';

export interface ListingWithDetails extends Listing {
  product: Product;
  variety: ProductVariety | null;
  unit: UnitOfMeasure;
  farmer: Farmer & { profile: Profile };
  images: string[];
  currency: Currency;
}

export interface TenderWithDetails extends Tender {
  product: Product;
  variety: ProductVariety | null;
  unit: UnitOfMeasure;
  store: Store & { profile: Profile };
  currency: Currency;
  offers_count: number;
}

export interface OrderWithDetails extends Order {
  items: OrderItemWithProduct[];
  farmer: Farmer & { profile: Profile };
  store: Store & { profile: Profile };
  review: Review | null;
}

export interface OrderItemWithProduct extends OrderItem {
  product: Product;
  variety: ProductVariety | null;
  unit: UnitOfMeasure;
}

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

export interface TenderOfferWithFarmer extends TenderOffer {
  farmer: Farmer & { profile: Profile };
}

export interface CroppingPlanWithDetails extends CroppingPlan {
  product: Product;
  variety: ProductVariety | null;
  unit: UnitOfMeasure;
  contract: Contract | null;
}

export interface FarmerPublicProfile extends Farmer {
  profile: Profile;
  products: Product[];
  active_listings_count: number;
}

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
