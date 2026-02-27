-- Migration: Create all triggers
-- Description: Triggers for updated_at auto-update, farmer rating recalculation, listing/tender auto-status updates

-- ============================================
-- UPDATED_AT AUTO-UPDATE TRIGGER
-- ============================================

-- Reusable function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at column
CREATE TRIGGER trigger_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_farmers_updated_at
    BEFORE UPDATE ON public.farmers
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_stores_updated_at
    BEFORE UPDATE ON public.stores
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_product_categories_updated_at
    BEFORE UPDATE ON public.product_categories
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_products_updated_at
    BEFORE UPDATE ON public.products
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_listings_updated_at
    BEFORE UPDATE ON public.listings
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_cropping_plans_updated_at
    BEFORE UPDATE ON public.cropping_plans
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_tenders_updated_at
    BEFORE UPDATE ON public.tenders
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_tender_offers_updated_at
    BEFORE UPDATE ON public.tender_offers
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_contracts_updated_at
    BEFORE UPDATE ON public.contracts
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_contract_deliveries_updated_at
    BEFORE UPDATE ON public.contract_deliveries
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_orders_updated_at
    BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trigger_order_items_updated_at
    BEFORE UPDATE ON public.order_items
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- ============================================
-- FARMER RATING RECALCULATION TRIGGER
-- ============================================

-- Function to recalculate farmer's aggregate ratings after a new review
CREATE OR REPLACE FUNCTION public.recalculate_farmer_ratings()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.farmers SET
        avg_overall_rating = (
            SELECT ROUND(AVG(overall_rating)::numeric, 2)
            FROM public.reviews
            WHERE farmer_id = NEW.farmer_id
        ),
        avg_quality_rating = (
            SELECT ROUND(AVG(quality_rating)::numeric, 2)
            FROM public.reviews
            WHERE farmer_id = NEW.farmer_id
        ),
        avg_reliability_rating = (
            SELECT ROUND(AVG(reliability_rating)::numeric, 2)
            FROM public.reviews
            WHERE farmer_id = NEW.farmer_id
        ),
        total_reviews = (
            SELECT COUNT(*)
            FROM public.reviews
            WHERE farmer_id = NEW.farmer_id
        ),
        total_transactions = (
            SELECT COUNT(*)
            FROM public.orders
            WHERE farmer_id = NEW.farmer_id
            AND status = 'confirmed'
        ),
        updated_at = NOW()
    WHERE id = NEW.farmer_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger after review is created
CREATE TRIGGER on_review_created
    AFTER INSERT ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.recalculate_farmer_ratings();

-- ============================================
-- LISTING AUTO-SOLD TRIGGER
-- ============================================

-- Function to auto-update listing status to 'sold' when quantity_remaining hits 0
CREATE OR REPLACE FUNCTION public.check_listing_sold()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantity_remaining <= 0 AND NEW.status = 'active' THEN
        NEW.status := 'sold';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger before update when quantity_remaining changes
CREATE TRIGGER on_listing_quantity_changed
    BEFORE UPDATE ON public.listings
    FOR EACH ROW
    WHEN (OLD.quantity_remaining IS DISTINCT FROM NEW.quantity_remaining)
    EXECUTE FUNCTION public.check_listing_sold();

-- ============================================
-- TENDER AUTO-FULFILLED TRIGGER
-- ============================================

-- Function to auto-update tender status to 'fulfilled' when quantity_fulfilled >= quantity_needed
CREATE OR REPLACE FUNCTION public.check_tender_fulfilled()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantity_fulfilled >= NEW.quantity_needed AND NEW.status = 'active' THEN
        NEW.status := 'fulfilled';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger before update when quantity_fulfilled changes
CREATE TRIGGER on_tender_fulfillment_changed
    BEFORE UPDATE ON public.tenders
    FOR EACH ROW
    WHEN (OLD.quantity_fulfilled IS DISTINCT FROM NEW.quantity_fulfilled)
    EXECUTE FUNCTION public.check_tender_fulfilled();
