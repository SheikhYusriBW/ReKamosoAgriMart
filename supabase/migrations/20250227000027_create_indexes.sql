-- Migration: Create all indexes for query performance
-- Description: Indexes for all frequently queried columns as specified in DATABASE_SCHEMA.md

-- ============================================
-- LISTINGS INDEXES
-- Farmers and stores browse/filter these heavily
-- ============================================
CREATE INDEX idx_listings_status ON public.listings(status);
CREATE INDEX idx_listings_product ON public.listings(product_id);
CREATE INDEX idx_listings_farmer ON public.listings(farmer_id);
CREATE INDEX idx_listings_available ON public.listings(available_from, available_until);

-- ============================================
-- ORDERS INDEXES
-- Filtered by store, farmer, status
-- ============================================
CREATE INDEX idx_orders_store ON public.orders(store_id);
CREATE INDEX idx_orders_farmer ON public.orders(farmer_id);
CREATE INDEX idx_orders_status ON public.orders(status);
CREATE INDEX idx_orders_source ON public.orders(source);

-- ============================================
-- TENDERS INDEXES
-- Stores post, farmers browse
-- ============================================
CREATE INDEX idx_tenders_store ON public.tenders(store_id);
CREATE INDEX idx_tenders_product ON public.tenders(product_id);
CREATE INDEX idx_tenders_status ON public.tenders(status);

-- ============================================
-- CONTRACTS INDEXES
-- Both parties query
-- ============================================
CREATE INDEX idx_contracts_store ON public.contracts(store_id);
CREATE INDEX idx_contracts_farmer ON public.contracts(farmer_id);
CREATE INDEX idx_contracts_status ON public.contracts(status);

-- ============================================
-- CROPPING PLANS INDEXES
-- Stores browse for forward visibility
-- ============================================
CREATE INDEX idx_cropping_plans_farmer ON public.cropping_plans(farmer_id);
CREATE INDEX idx_cropping_plans_product ON public.cropping_plans(product_id);
CREATE INDEX idx_cropping_plans_harvest ON public.cropping_plans(expected_harvest_date);

-- ============================================
-- NOTIFICATIONS INDEXES
-- User's notification feed
-- ============================================
CREATE INDEX idx_notifications_recipient ON public.notifications(recipient_id);
CREATE INDEX idx_notifications_read ON public.notifications(recipient_id, is_read);

-- ============================================
-- REVIEWS INDEXES
-- Aggregate queries for farmer ratings
-- ============================================
CREATE INDEX idx_reviews_farmer ON public.reviews(farmer_id);

-- ============================================
-- FARMER PRODUCTS INDEXES
-- Matching farmers to tenders/contracts
-- ============================================
CREATE INDEX idx_farmer_products_farmer ON public.farmer_products(farmer_id);
CREATE INDEX idx_farmer_products_product ON public.farmer_products(product_id);

-- ============================================
-- USER ROLES INDEXES
-- Checked on every login and role switch
-- ============================================
CREATE INDEX idx_user_roles_profile ON public.user_roles(profile_id);
CREATE INDEX idx_user_roles_active ON public.user_roles(profile_id, is_active);
