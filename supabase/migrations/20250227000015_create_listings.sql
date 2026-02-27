-- Migration: Create listings table
-- Description: Farmer produce listings for the spot market. The core of the marketplace.
--
-- CRITICAL: quantity_remaining MUST use atomic updates via RPC functions (see migration 30).
-- Never read-then-write from the client - this will cause overselling under concurrent load.
-- Use the decrement_listing_quantity() RPC function for all quantity updates.

CREATE TABLE public.listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES public.farmers(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    variety_id UUID REFERENCES public.product_varieties(id) ON DELETE SET NULL,
    title VARCHAR(255),
    description TEXT,
    quantity DECIMAL(12,2) NOT NULL,
    quantity_remaining DECIMAL(12,2) NOT NULL,
    unit_id UUID NOT NULL REFERENCES public.units_of_measure(id) ON DELETE RESTRICT,
    price_per_unit DECIMAL(12,2) NOT NULL,
    currency_code VARCHAR(3) NOT NULL DEFAULT 'BWP',
    quality_grade VARCHAR(20),
    available_from DATE NOT NULL,
    available_until DATE NOT NULL,
    delivery_options VARCHAR(20) NOT NULL DEFAULT 'either',
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Valid delivery options
    CONSTRAINT chk_listings_delivery_options CHECK (
        delivery_options IN ('farmer_delivers', 'store_collects', 'either')
    ),

    -- Valid statuses
    CONSTRAINT chk_listings_status CHECK (
        status IN ('draft', 'active', 'sold', 'expired', 'cancelled')
    ),

    -- quantity_remaining cannot exceed quantity
    CONSTRAINT chk_listings_quantity_remaining CHECK (
        quantity_remaining >= 0 AND quantity_remaining <= quantity
    ),

    -- Dates must be logical
    CONSTRAINT chk_listings_dates CHECK (
        available_until >= available_from
    )
);

-- Add table comment
COMMENT ON TABLE public.listings IS 'Farmer produce listings for spot market. CRITICAL: quantity_remaining must use atomic RPC updates only.';

-- Add column comments
COMMENT ON COLUMN public.listings.farmer_id IS 'Farmer who created the listing';
COMMENT ON COLUMN public.listings.product_id IS 'Product being sold';
COMMENT ON COLUMN public.listings.variety_id IS 'Specific variety (optional)';
COMMENT ON COLUMN public.listings.title IS 'Optional custom title';
COMMENT ON COLUMN public.listings.quantity IS 'Total quantity available';
COMMENT ON COLUMN public.listings.quantity_remaining IS 'Quantity not yet claimed - MUST use atomic updates via RPC';
COMMENT ON COLUMN public.listings.unit_id IS 'Unit of measure';
COMMENT ON COLUMN public.listings.price_per_unit IS 'Price per unit';
COMMENT ON COLUMN public.listings.currency_code IS 'Currency ISO 4217 code';
COMMENT ON COLUMN public.listings.quality_grade IS 'Quality grade: A, B, C or free text';
COMMENT ON COLUMN public.listings.available_from IS 'Start of availability window';
COMMENT ON COLUMN public.listings.available_until IS 'End of availability window';
COMMENT ON COLUMN public.listings.delivery_options IS 'Who handles delivery';
COMMENT ON COLUMN public.listings.status IS 'Listing status - auto-updates to sold when quantity_remaining = 0';
