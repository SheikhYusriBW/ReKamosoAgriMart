-- Migration: Create tender_offers table
-- Description: Farmer responses/bids on store tenders.

CREATE TABLE public.tender_offers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tender_id UUID NOT NULL REFERENCES public.tenders(id) ON DELETE CASCADE,
    farmer_id UUID NOT NULL REFERENCES public.farmers(id) ON DELETE CASCADE,
    quantity_offered DECIMAL(12,2) NOT NULL,
    price_per_unit DECIMAL(12,2) NOT NULL,
    currency_code VARCHAR(3) NOT NULL DEFAULT 'BWP',
    delivery_date DATE NOT NULL,
    delivery_method VARCHAR(20) NOT NULL DEFAULT 'either',
    notes TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    responded_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- A farmer can only submit one offer per tender
    CONSTRAINT uq_tender_offers_tender_farmer UNIQUE (tender_id, farmer_id),

    -- Valid delivery methods
    CONSTRAINT chk_tender_offers_delivery_method CHECK (
        delivery_method IN ('farmer_delivers', 'store_collects', 'either')
    ),

    -- Valid statuses
    CONSTRAINT chk_tender_offers_status CHECK (
        status IN ('pending', 'accepted', 'declined')
    )
);

-- Add table comment
COMMENT ON TABLE public.tender_offers IS 'Farmer responses/bids on store tenders. One offer per farmer per tender.';

-- Add column comments
COMMENT ON COLUMN public.tender_offers.tender_id IS 'Which tender this offer is for';
COMMENT ON COLUMN public.tender_offers.farmer_id IS 'Farmer making the offer';
COMMENT ON COLUMN public.tender_offers.quantity_offered IS 'How much the farmer can supply';
COMMENT ON COLUMN public.tender_offers.price_per_unit IS 'Farmer offered price per unit';
COMMENT ON COLUMN public.tender_offers.currency_code IS 'Currency ISO 4217 code';
COMMENT ON COLUMN public.tender_offers.delivery_date IS 'When the farmer can deliver';
COMMENT ON COLUMN public.tender_offers.delivery_method IS 'Delivery method';
COMMENT ON COLUMN public.tender_offers.notes IS 'Additional details from farmer';
COMMENT ON COLUMN public.tender_offers.status IS 'Offer status: pending, accepted, declined';
COMMENT ON COLUMN public.tender_offers.responded_at IS 'When store accepted/declined';
