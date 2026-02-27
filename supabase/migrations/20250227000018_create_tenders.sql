-- Migration: Create tenders table
-- Description: Store procurement requests. Stores broadcast what they need and farmers respond.
--
-- CRITICAL: quantity_fulfilled MUST use atomic updates via RPC functions (see migration 30).
-- Never read-then-write from the client - this will cause over-fulfillment under concurrent load.
-- Use the increment_tender_fulfillment() RPC function for all fulfillment updates.

CREATE TABLE public.tenders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    variety_id UUID REFERENCES public.product_varieties(id) ON DELETE SET NULL,
    quantity_needed DECIMAL(12,2) NOT NULL,
    unit_id UUID NOT NULL REFERENCES public.units_of_measure(id) ON DELETE RESTRICT,
    min_price DECIMAL(12,2),
    max_price DECIMAL(12,2),
    currency_code VARCHAR(3) NOT NULL DEFAULT 'BWP',
    date_needed_by DATE NOT NULL,
    quality_requirements TEXT,
    delivery_preference VARCHAR(20) NOT NULL DEFAULT 'either',
    quantity_fulfilled DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Valid delivery preferences
    CONSTRAINT chk_tenders_delivery_preference CHECK (
        delivery_preference IN ('farmer_delivers', 'store_collects', 'either')
    ),

    -- Valid statuses
    CONSTRAINT chk_tenders_status CHECK (
        status IN ('active', 'fulfilled', 'expired', 'cancelled')
    ),

    -- quantity_fulfilled cannot exceed quantity_needed
    CONSTRAINT chk_tenders_quantity_fulfilled CHECK (
        quantity_fulfilled >= 0 AND quantity_fulfilled <= quantity_needed
    ),

    -- Price range must be logical if both provided
    CONSTRAINT chk_tenders_price_range CHECK (
        min_price IS NULL OR max_price IS NULL OR max_price >= min_price
    )
);

-- Add table comment
COMMENT ON TABLE public.tenders IS 'Store procurement requests. CRITICAL: quantity_fulfilled must use atomic RPC updates only.';

-- Add column comments
COMMENT ON COLUMN public.tenders.store_id IS 'Store posting the tender';
COMMENT ON COLUMN public.tenders.product_id IS 'Product needed';
COMMENT ON COLUMN public.tenders.variety_id IS 'Specific variety needed (optional)';
COMMENT ON COLUMN public.tenders.quantity_needed IS 'How much the store needs';
COMMENT ON COLUMN public.tenders.unit_id IS 'Unit of measure';
COMMENT ON COLUMN public.tenders.min_price IS 'Minimum price willing to pay (optional)';
COMMENT ON COLUMN public.tenders.max_price IS 'Maximum price willing to pay (optional)';
COMMENT ON COLUMN public.tenders.currency_code IS 'Currency ISO 4217 code';
COMMENT ON COLUMN public.tenders.date_needed_by IS 'When the store needs the produce';
COMMENT ON COLUMN public.tenders.quality_requirements IS 'Quality standards description';
COMMENT ON COLUMN public.tenders.delivery_preference IS 'Delivery preference';
COMMENT ON COLUMN public.tenders.quantity_fulfilled IS 'Total quantity from accepted offers - MUST use atomic RPC updates';
COMMENT ON COLUMN public.tenders.status IS 'Tender status - auto-updates to fulfilled when quantity_fulfilled >= quantity_needed';
COMMENT ON COLUMN public.tenders.expires_at IS 'When the tender auto-expires';
