-- Migration: Create RLS policies for all tables
-- Description: Row Level Security policies to enforce data isolation between users and roles

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Check if current user is an admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_roles
        WHERE profile_id = auth.uid()
        AND role = 'admin'
        AND is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Check if current user has a specific role
CREATE OR REPLACE FUNCTION public.has_role(required_role TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_roles
        WHERE profile_id = auth.uid()
        AND role = required_role
        AND is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Get current user's farmer_id
CREATE OR REPLACE FUNCTION public.get_farmer_id()
RETURNS UUID AS $$
BEGIN
    RETURN (
        SELECT id FROM public.farmers
        WHERE profile_id = auth.uid()
        LIMIT 1
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Get current user's store_id
CREATE OR REPLACE FUNCTION public.get_store_id()
RETURNS UUID AS $$
BEGIN
    RETURN (
        SELECT id FROM public.stores
        WHERE profile_id = auth.uid()
        LIMIT 1
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================
-- ENABLE RLS ON ALL TABLES
-- ============================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.currencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.countries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.farmers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.farm_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_varieties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.units_of_measure ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.farmer_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listing_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cropping_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tender_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.platform_settings ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PROFILES POLICIES
-- ============================================
-- Users can SELECT their own profile
CREATE POLICY profiles_select_own ON public.profiles
    FOR SELECT USING (id = auth.uid());

-- Users can UPDATE their own profile
CREATE POLICY profiles_update_own ON public.profiles
    FOR UPDATE USING (id = auth.uid());

-- Admins can SELECT all profiles
CREATE POLICY profiles_admin_select ON public.profiles
    FOR SELECT USING (public.is_admin());

-- ============================================
-- USER_ROLES POLICIES
-- ============================================
-- Users can SELECT their own roles
CREATE POLICY user_roles_select_own ON public.user_roles
    FOR SELECT USING (profile_id = auth.uid());

-- Admins can SELECT all roles
CREATE POLICY user_roles_admin_select ON public.user_roles
    FOR SELECT USING (public.is_admin());

-- Only admins can INSERT roles (except via SECURITY DEFINER functions)
CREATE POLICY user_roles_admin_insert ON public.user_roles
    FOR INSERT WITH CHECK (public.is_admin());

-- Only admins can UPDATE roles
CREATE POLICY user_roles_admin_update ON public.user_roles
    FOR UPDATE USING (public.is_admin());

-- Only admins can DELETE roles
CREATE POLICY user_roles_admin_delete ON public.user_roles
    FOR DELETE USING (public.is_admin());

-- ============================================
-- CURRENCIES POLICIES
-- ============================================
-- All authenticated users can SELECT active currencies
CREATE POLICY currencies_select_active ON public.currencies
    FOR SELECT USING (is_active = true);

-- Admins can SELECT all
CREATE POLICY currencies_admin_select ON public.currencies
    FOR SELECT USING (public.is_admin());

-- Only admins can INSERT/UPDATE/DELETE
CREATE POLICY currencies_admin_insert ON public.currencies
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY currencies_admin_update ON public.currencies
    FOR UPDATE USING (public.is_admin());

CREATE POLICY currencies_admin_delete ON public.currencies
    FOR DELETE USING (public.is_admin());

-- ============================================
-- COUNTRIES POLICIES
-- ============================================
-- All authenticated users can SELECT active countries
CREATE POLICY countries_select_active ON public.countries
    FOR SELECT USING (is_active = true);

-- Admins can SELECT all
CREATE POLICY countries_admin_select ON public.countries
    FOR SELECT USING (public.is_admin());

-- Only admins can INSERT/UPDATE/DELETE
CREATE POLICY countries_admin_insert ON public.countries
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY countries_admin_update ON public.countries
    FOR UPDATE USING (public.is_admin());

CREATE POLICY countries_admin_delete ON public.countries
    FOR DELETE USING (public.is_admin());

-- ============================================
-- FARMERS POLICIES
-- ============================================
-- Farmers can SELECT their own record
CREATE POLICY farmers_select_own ON public.farmers
    FOR SELECT USING (profile_id = auth.uid());

-- Farmers can UPDATE their own record
CREATE POLICY farmers_update_own ON public.farmers
    FOR UPDATE USING (profile_id = auth.uid());

-- Stores can SELECT approved farmer profiles
CREATE POLICY farmers_store_select_approved ON public.farmers
    FOR SELECT USING (
        public.has_role('store') AND verification_status = 'approved'
    );

-- Admins can SELECT all
CREATE POLICY farmers_admin_select ON public.farmers
    FOR SELECT USING (public.is_admin());

-- Admins can UPDATE all
CREATE POLICY farmers_admin_update ON public.farmers
    FOR UPDATE USING (public.is_admin());

-- Farmers can INSERT their own record (during registration)
CREATE POLICY farmers_insert_own ON public.farmers
    FOR INSERT WITH CHECK (profile_id = auth.uid());

-- ============================================
-- FARM_IMAGES POLICIES
-- ============================================
-- Farmers can CRUD their own farm images
CREATE POLICY farm_images_farmer_select ON public.farm_images
    FOR SELECT USING (farmer_id = public.get_farmer_id());

CREATE POLICY farm_images_farmer_insert ON public.farm_images
    FOR INSERT WITH CHECK (farmer_id = public.get_farmer_id());

CREATE POLICY farm_images_farmer_update ON public.farm_images
    FOR UPDATE USING (farmer_id = public.get_farmer_id());

CREATE POLICY farm_images_farmer_delete ON public.farm_images
    FOR DELETE USING (farmer_id = public.get_farmer_id());

-- Public can SELECT all (for display on farmer profiles)
CREATE POLICY farm_images_public_select ON public.farm_images
    FOR SELECT USING (true);

-- ============================================
-- STORES POLICIES
-- ============================================
-- Stores can SELECT their own record
CREATE POLICY stores_select_own ON public.stores
    FOR SELECT USING (profile_id = auth.uid());

-- Stores can UPDATE their own record
CREATE POLICY stores_update_own ON public.stores
    FOR UPDATE USING (profile_id = auth.uid());

-- Farmers can SELECT active stores
CREATE POLICY stores_farmer_select_active ON public.stores
    FOR SELECT USING (
        public.has_role('farmer') AND is_active = true
    );

-- Admins can SELECT all
CREATE POLICY stores_admin_select ON public.stores
    FOR SELECT USING (public.is_admin());

-- Admins can UPDATE all
CREATE POLICY stores_admin_update ON public.stores
    FOR UPDATE USING (public.is_admin());

-- Stores can INSERT their own record (during registration)
CREATE POLICY stores_insert_own ON public.stores
    FOR INSERT WITH CHECK (profile_id = auth.uid());

-- ============================================
-- ADMIN_USERS POLICIES
-- ============================================
-- Only admins can access this table
CREATE POLICY admin_users_admin_select ON public.admin_users
    FOR SELECT USING (public.is_admin());

CREATE POLICY admin_users_admin_insert ON public.admin_users
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY admin_users_admin_update ON public.admin_users
    FOR UPDATE USING (public.is_admin());

CREATE POLICY admin_users_admin_delete ON public.admin_users
    FOR DELETE USING (public.is_admin());

-- ============================================
-- PRODUCT_CATEGORIES POLICIES
-- ============================================
-- All authenticated users can SELECT active categories
CREATE POLICY product_categories_select_active ON public.product_categories
    FOR SELECT USING (is_active = true);

-- Admins can SELECT all
CREATE POLICY product_categories_admin_select ON public.product_categories
    FOR SELECT USING (public.is_admin());

-- Only admins can INSERT/UPDATE/DELETE
CREATE POLICY product_categories_admin_insert ON public.product_categories
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY product_categories_admin_update ON public.product_categories
    FOR UPDATE USING (public.is_admin());

CREATE POLICY product_categories_admin_delete ON public.product_categories
    FOR DELETE USING (public.is_admin());

-- ============================================
-- PRODUCTS POLICIES
-- ============================================
-- All authenticated users can SELECT active products
CREATE POLICY products_select_active ON public.products
    FOR SELECT USING (is_active = true);

-- Admins can SELECT all
CREATE POLICY products_admin_select ON public.products
    FOR SELECT USING (public.is_admin());

-- Only admins can INSERT/UPDATE/DELETE
CREATE POLICY products_admin_insert ON public.products
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY products_admin_update ON public.products
    FOR UPDATE USING (public.is_admin());

CREATE POLICY products_admin_delete ON public.products
    FOR DELETE USING (public.is_admin());

-- ============================================
-- PRODUCT_VARIETIES POLICIES
-- ============================================
-- All authenticated users can SELECT active varieties
CREATE POLICY product_varieties_select_active ON public.product_varieties
    FOR SELECT USING (is_active = true);

-- Admins can SELECT all
CREATE POLICY product_varieties_admin_select ON public.product_varieties
    FOR SELECT USING (public.is_admin());

-- Only admins can INSERT/UPDATE/DELETE
CREATE POLICY product_varieties_admin_insert ON public.product_varieties
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY product_varieties_admin_update ON public.product_varieties
    FOR UPDATE USING (public.is_admin());

CREATE POLICY product_varieties_admin_delete ON public.product_varieties
    FOR DELETE USING (public.is_admin());

-- ============================================
-- PRODUCT_REQUESTS POLICIES
-- ============================================
-- Farmers can INSERT their own requests
CREATE POLICY product_requests_farmer_insert ON public.product_requests
    FOR INSERT WITH CHECK (farmer_id = public.get_farmer_id());

-- Farmers can SELECT their own requests
CREATE POLICY product_requests_farmer_select ON public.product_requests
    FOR SELECT USING (farmer_id = public.get_farmer_id());

-- Admins can SELECT all
CREATE POLICY product_requests_admin_select ON public.product_requests
    FOR SELECT USING (public.is_admin());

-- Admins can UPDATE (approve/reject)
CREATE POLICY product_requests_admin_update ON public.product_requests
    FOR UPDATE USING (public.is_admin());

-- ============================================
-- UNITS_OF_MEASURE POLICIES
-- ============================================
-- All authenticated users can SELECT active units
CREATE POLICY units_of_measure_select_active ON public.units_of_measure
    FOR SELECT USING (is_active = true);

-- Admins can SELECT all
CREATE POLICY units_of_measure_admin_select ON public.units_of_measure
    FOR SELECT USING (public.is_admin());

-- Only admins can INSERT/UPDATE/DELETE
CREATE POLICY units_of_measure_admin_insert ON public.units_of_measure
    FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY units_of_measure_admin_update ON public.units_of_measure
    FOR UPDATE USING (public.is_admin());

CREATE POLICY units_of_measure_admin_delete ON public.units_of_measure
    FOR DELETE USING (public.is_admin());

-- ============================================
-- FARMER_PRODUCTS POLICIES
-- ============================================
-- Farmers can CRUD their own links
CREATE POLICY farmer_products_farmer_select ON public.farmer_products
    FOR SELECT USING (farmer_id = public.get_farmer_id());

CREATE POLICY farmer_products_farmer_insert ON public.farmer_products
    FOR INSERT WITH CHECK (farmer_id = public.get_farmer_id());

CREATE POLICY farmer_products_farmer_delete ON public.farmer_products
    FOR DELETE USING (farmer_id = public.get_farmer_id());

-- Stores can SELECT (to see what farmers grow)
CREATE POLICY farmer_products_store_select ON public.farmer_products
    FOR SELECT USING (public.has_role('store'));

-- Admins can SELECT all
CREATE POLICY farmer_products_admin_select ON public.farmer_products
    FOR SELECT USING (public.is_admin());

-- ============================================
-- LISTINGS POLICIES
-- ============================================
-- Farmers can INSERT their own listings
CREATE POLICY listings_farmer_insert ON public.listings
    FOR INSERT WITH CHECK (farmer_id = public.get_farmer_id());

-- Farmers can UPDATE their own listings
CREATE POLICY listings_farmer_update ON public.listings
    FOR UPDATE USING (farmer_id = public.get_farmer_id());

-- Farmers can DELETE their own listings
CREATE POLICY listings_farmer_delete ON public.listings
    FOR DELETE USING (farmer_id = public.get_farmer_id());

-- Farmers can SELECT their own listings
CREATE POLICY listings_farmer_select_own ON public.listings
    FOR SELECT USING (farmer_id = public.get_farmer_id());

-- All authenticated users can SELECT active listings
CREATE POLICY listings_select_active ON public.listings
    FOR SELECT USING (status = 'active');

-- Admins can SELECT all
CREATE POLICY listings_admin_select ON public.listings
    FOR SELECT USING (public.is_admin());

-- ============================================
-- LISTING_IMAGES POLICIES
-- ============================================
-- Farmers can CRUD images on their own listings
CREATE POLICY listing_images_farmer_select ON public.listing_images
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.listings
            WHERE listings.id = listing_images.listing_id
            AND listings.farmer_id = public.get_farmer_id()
        )
    );

CREATE POLICY listing_images_farmer_insert ON public.listing_images
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.listings
            WHERE listings.id = listing_images.listing_id
            AND listings.farmer_id = public.get_farmer_id()
        )
    );

CREATE POLICY listing_images_farmer_update ON public.listing_images
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.listings
            WHERE listings.id = listing_images.listing_id
            AND listings.farmer_id = public.get_farmer_id()
        )
    );

CREATE POLICY listing_images_farmer_delete ON public.listing_images
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.listings
            WHERE listings.id = listing_images.listing_id
            AND listings.farmer_id = public.get_farmer_id()
        )
    );

-- Public can SELECT all
CREATE POLICY listing_images_public_select ON public.listing_images
    FOR SELECT USING (true);

-- ============================================
-- CROPPING_PLANS POLICIES
-- ============================================
-- Farmers can CRUD their own plans
CREATE POLICY cropping_plans_farmer_select ON public.cropping_plans
    FOR SELECT USING (farmer_id = public.get_farmer_id());

CREATE POLICY cropping_plans_farmer_insert ON public.cropping_plans
    FOR INSERT WITH CHECK (farmer_id = public.get_farmer_id());

CREATE POLICY cropping_plans_farmer_update ON public.cropping_plans
    FOR UPDATE USING (farmer_id = public.get_farmer_id());

CREATE POLICY cropping_plans_farmer_delete ON public.cropping_plans
    FOR DELETE USING (farmer_id = public.get_farmer_id());

-- Stores can SELECT all plans (forward visibility)
CREATE POLICY cropping_plans_store_select ON public.cropping_plans
    FOR SELECT USING (public.has_role('store'));

-- Admins can SELECT all
CREATE POLICY cropping_plans_admin_select ON public.cropping_plans
    FOR SELECT USING (public.is_admin());

-- ============================================
-- TENDERS POLICIES
-- ============================================
-- Stores can CRUD their own tenders
CREATE POLICY tenders_store_select ON public.tenders
    FOR SELECT USING (store_id = public.get_store_id());

CREATE POLICY tenders_store_insert ON public.tenders
    FOR INSERT WITH CHECK (store_id = public.get_store_id());

CREATE POLICY tenders_store_update ON public.tenders
    FOR UPDATE USING (store_id = public.get_store_id());

CREATE POLICY tenders_store_delete ON public.tenders
    FOR DELETE USING (store_id = public.get_store_id());

-- Approved farmers can SELECT active tenders
CREATE POLICY tenders_farmer_select_active ON public.tenders
    FOR SELECT USING (
        public.has_role('farmer')
        AND status = 'active'
        AND EXISTS (
            SELECT 1 FROM public.farmers
            WHERE farmers.profile_id = auth.uid()
            AND farmers.verification_status = 'approved'
        )
    );

-- Admins can SELECT all
CREATE POLICY tenders_admin_select ON public.tenders
    FOR SELECT USING (public.is_admin());

-- ============================================
-- TENDER_OFFERS POLICIES
-- ============================================
-- Farmers can INSERT their own offers
CREATE POLICY tender_offers_farmer_insert ON public.tender_offers
    FOR INSERT WITH CHECK (farmer_id = public.get_farmer_id());

-- Farmers can SELECT their own offers
CREATE POLICY tender_offers_farmer_select ON public.tender_offers
    FOR SELECT USING (farmer_id = public.get_farmer_id());

-- Stores can SELECT offers on their own tenders
CREATE POLICY tender_offers_store_select ON public.tender_offers
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.tenders
            WHERE tenders.id = tender_offers.tender_id
            AND tenders.store_id = public.get_store_id()
        )
    );

-- Stores can UPDATE offers on their own tenders (accept/decline)
CREATE POLICY tender_offers_store_update ON public.tender_offers
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.tenders
            WHERE tenders.id = tender_offers.tender_id
            AND tenders.store_id = public.get_store_id()
        )
    );

-- Admins can SELECT all
CREATE POLICY tender_offers_admin_select ON public.tender_offers
    FOR SELECT USING (public.is_admin());

-- ============================================
-- CONTRACTS POLICIES
-- ============================================
-- Stores can INSERT their own contracts
CREATE POLICY contracts_store_insert ON public.contracts
    FOR INSERT WITH CHECK (store_id = public.get_store_id());

-- Stores can SELECT their own contracts
CREATE POLICY contracts_store_select ON public.contracts
    FOR SELECT USING (store_id = public.get_store_id());

-- Stores can UPDATE their own contracts
CREATE POLICY contracts_store_update ON public.contracts
    FOR UPDATE USING (store_id = public.get_store_id());

-- Farmers can SELECT contracts where they are the farmer_id OR where is_public = true
CREATE POLICY contracts_farmer_select ON public.contracts
    FOR SELECT USING (
        farmer_id = public.get_farmer_id()
        OR (is_public = true AND status = 'open')
    );

-- Farmers can UPDATE contracts to accept (set farmer_id, only when farmer_id IS NULL)
CREATE POLICY contracts_farmer_accept ON public.contracts
    FOR UPDATE USING (
        farmer_id IS NULL
        AND is_public = true
        AND status = 'open'
    );

-- Admins can SELECT all
CREATE POLICY contracts_admin_select ON public.contracts
    FOR SELECT USING (public.is_admin());

-- ============================================
-- CONTRACT_DELIVERIES POLICIES
-- ============================================
-- Farmers can SELECT deliveries on their contracts
CREATE POLICY contract_deliveries_farmer_select ON public.contract_deliveries
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.contracts
            WHERE contracts.id = contract_deliveries.contract_id
            AND contracts.farmer_id = public.get_farmer_id()
        )
    );

-- Farmers can UPDATE deliveries on their contracts
CREATE POLICY contract_deliveries_farmer_update ON public.contract_deliveries
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.contracts
            WHERE contracts.id = contract_deliveries.contract_id
            AND contracts.farmer_id = public.get_farmer_id()
        )
    );

-- Stores can SELECT deliveries on their contracts
CREATE POLICY contract_deliveries_store_select ON public.contract_deliveries
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.contracts
            WHERE contracts.id = contract_deliveries.contract_id
            AND contracts.store_id = public.get_store_id()
        )
    );

-- Stores can UPDATE deliveries on their contracts
CREATE POLICY contract_deliveries_store_update ON public.contract_deliveries
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.contracts
            WHERE contracts.id = contract_deliveries.contract_id
            AND contracts.store_id = public.get_store_id()
        )
    );

-- Admins can SELECT all
CREATE POLICY contract_deliveries_admin_select ON public.contract_deliveries
    FOR SELECT USING (public.is_admin());

-- ============================================
-- ORDERS POLICIES
-- ============================================
-- Stores can INSERT orders
CREATE POLICY orders_store_insert ON public.orders
    FOR INSERT WITH CHECK (store_id = public.get_store_id());

-- Stores can SELECT their own orders
CREATE POLICY orders_store_select ON public.orders
    FOR SELECT USING (store_id = public.get_store_id());

-- Stores can UPDATE their own orders
CREATE POLICY orders_store_update ON public.orders
    FOR UPDATE USING (store_id = public.get_store_id());

-- Farmers can SELECT their own orders
CREATE POLICY orders_farmer_select ON public.orders
    FOR SELECT USING (farmer_id = public.get_farmer_id());

-- Farmers can UPDATE their own orders (status changes)
CREATE POLICY orders_farmer_update ON public.orders
    FOR UPDATE USING (farmer_id = public.get_farmer_id());

-- Admins can SELECT all
CREATE POLICY orders_admin_select ON public.orders
    FOR SELECT USING (public.is_admin());

-- ============================================
-- ORDER_ITEMS POLICIES
-- ============================================
-- Stores can SELECT items on their own orders
CREATE POLICY order_items_store_select ON public.order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.store_id = public.get_store_id()
        )
    );

-- Stores can INSERT items on their own orders
CREATE POLICY order_items_store_insert ON public.order_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.store_id = public.get_store_id()
        )
    );

-- Farmers can SELECT items on their own orders
CREATE POLICY order_items_farmer_select ON public.order_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.farmer_id = public.get_farmer_id()
        )
    );

-- Admins can SELECT all
CREATE POLICY order_items_admin_select ON public.order_items
    FOR SELECT USING (public.is_admin());

-- ============================================
-- REVIEWS POLICIES
-- ============================================
-- Stores can INSERT reviews on their own completed orders
CREATE POLICY reviews_store_insert ON public.reviews
    FOR INSERT WITH CHECK (
        store_id = public.get_store_id()
        AND EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = reviews.order_id
            AND orders.store_id = public.get_store_id()
            AND orders.status = 'confirmed'
        )
    );

-- All authenticated users can SELECT all reviews (public reputation)
CREATE POLICY reviews_select_all ON public.reviews
    FOR SELECT USING (auth.uid() IS NOT NULL);

-- Admins can SELECT all (redundant but explicit)
CREATE POLICY reviews_admin_select ON public.reviews
    FOR SELECT USING (public.is_admin());

-- ============================================
-- NOTIFICATIONS POLICIES
-- ============================================
-- Users can SELECT their own notifications
CREATE POLICY notifications_select_own ON public.notifications
    FOR SELECT USING (recipient_id = auth.uid());

-- Users can UPDATE their own notifications (mark read)
CREATE POLICY notifications_update_own ON public.notifications
    FOR UPDATE USING (recipient_id = auth.uid());

-- Note: INSERT is done by Edge Functions using service_role key (bypasses RLS)

-- ============================================
-- PLATFORM_SETTINGS POLICIES
-- ============================================
-- All authenticated users can SELECT
CREATE POLICY platform_settings_select_all ON public.platform_settings
    FOR SELECT USING (auth.uid() IS NOT NULL);

-- Only admins can UPDATE
CREATE POLICY platform_settings_admin_update ON public.platform_settings
    FOR UPDATE USING (public.is_admin());

-- Only admins can INSERT (for adding new settings)
CREATE POLICY platform_settings_admin_insert ON public.platform_settings
    FOR INSERT WITH CHECK (public.is_admin());
