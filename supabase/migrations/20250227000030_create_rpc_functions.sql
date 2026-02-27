-- Migration: Create RPC functions for atomic operations
-- Description: CRITICAL functions for atomic updates to prevent race conditions and overselling

-- ============================================
-- ATOMIC LISTING QUANTITY DECREMENT
-- CRITICAL: Prevents overselling under concurrent load
-- ============================================

CREATE OR REPLACE FUNCTION public.decrement_listing_quantity(
    p_listing_id UUID,
    p_ordered_qty DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
    v_remaining DECIMAL;
BEGIN
    -- Atomic update with row-level locking
    -- Only succeeds if there's enough quantity AND listing is active
    UPDATE public.listings
    SET quantity_remaining = quantity_remaining - p_ordered_qty,
        updated_at = NOW()
    WHERE id = p_listing_id
        AND quantity_remaining >= p_ordered_qty
        AND status = 'active'
    RETURNING quantity_remaining INTO v_remaining;

    -- Returns NULL if update failed (insufficient quantity or wrong status)
    -- The calling code should check for NULL and handle gracefully
    RETURN v_remaining;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.decrement_listing_quantity IS 'Atomically decrement listing quantity. Returns remaining qty or NULL if insufficient stock.';

-- ============================================
-- ATOMIC TENDER FULFILLMENT INCREMENT
-- Prevents over-fulfillment when multiple offers are accepted concurrently
-- ============================================

CREATE OR REPLACE FUNCTION public.increment_tender_fulfillment(
    p_tender_id UUID,
    p_fulfilled_qty DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
    v_fulfilled DECIMAL;
BEGIN
    -- Atomic update with row-level locking
    UPDATE public.tenders
    SET quantity_fulfilled = quantity_fulfilled + p_fulfilled_qty,
        updated_at = NOW()
    WHERE id = p_tender_id
        AND status = 'active'
    RETURNING quantity_fulfilled INTO v_fulfilled;

    RETURN v_fulfilled;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.increment_tender_fulfillment IS 'Atomically increment tender fulfillment. Returns new fulfilled qty.';

-- ============================================
-- ATOMIC CONTRACT DELIVERY UPDATE
-- Updates total_delivered_qty and recalculates fulfillment_rate
-- ============================================

CREATE OR REPLACE FUNCTION public.update_contract_delivery_totals(
    p_contract_id UUID,
    p_delivered_qty DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
    v_total DECIMAL;
    v_contracted DECIMAL;
BEGIN
    -- Atomic update to add delivered quantity
    UPDATE public.contracts
    SET total_delivered_qty = total_delivered_qty + p_delivered_qty,
        updated_at = NOW()
    WHERE id = p_contract_id
    RETURNING total_delivered_qty, total_contracted_qty INTO v_total, v_contracted;

    -- Recalculate fulfillment rate if we have a contracted quantity
    IF v_contracted > 0 THEN
        UPDATE public.contracts
        SET fulfillment_rate = ROUND((v_total / v_contracted * 100)::numeric, 2)
        WHERE id = p_contract_id;
    END IF;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.update_contract_delivery_totals IS 'Atomically update contract delivery totals and recalculate fulfillment rate.';

-- ============================================
-- ASSIGN USER ROLE
-- Used during registration to assign roles (bypasses RLS)
-- ============================================

CREATE OR REPLACE FUNCTION public.assign_user_role(
    p_profile_id UUID,
    p_role TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.user_roles (profile_id, role)
    VALUES (p_profile_id, p_role)
    ON CONFLICT (profile_id, role) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.assign_user_role IS 'Assign a role to a user during registration. Uses SECURITY DEFINER to bypass RLS.';

-- ============================================
-- GET COMMISSION RATE
-- Helper function to get current platform commission rate
-- ============================================

CREATE OR REPLACE FUNCTION public.get_commission_rate()
RETURNS DECIMAL AS $$
DECLARE
    v_rate DECIMAL;
BEGIN
    SELECT COALESCE(value::DECIMAL, 0)
    INTO v_rate
    FROM public.platform_settings
    WHERE key = 'commission_rate'
    LIMIT 1;

    RETURN COALESCE(v_rate, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

COMMENT ON FUNCTION public.get_commission_rate IS 'Get current platform commission rate from settings.';
