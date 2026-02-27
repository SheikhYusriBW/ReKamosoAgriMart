-- Migration: Create contract_deliveries table
-- Description: Individual deliveries logged against an active contract.

CREATE TABLE public.contract_deliveries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL REFERENCES public.contracts(id) ON DELETE CASCADE,
    expected_date DATE NOT NULL,
    actual_date DATE,
    expected_quantity DECIMAL(12,2) NOT NULL,
    actual_quantity DECIMAL(12,2),
    status VARCHAR(20) NOT NULL DEFAULT 'upcoming',
    farmer_notes TEXT,
    store_notes TEXT,
    quality_rating INTEGER,
    order_id UUID, -- FK added after orders table exists
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Valid statuses
    CONSTRAINT chk_contract_deliveries_status CHECK (
        status IN ('upcoming', 'due', 'delivered', 'confirmed', 'missed')
    ),

    -- Quality rating must be 1-5 if provided
    CONSTRAINT chk_contract_deliveries_quality_rating CHECK (
        quality_rating IS NULL OR (quality_rating >= 1 AND quality_rating <= 5)
    )
);

-- Add table comment
COMMENT ON TABLE public.contract_deliveries IS 'Individual delivery schedule entries against contracts. Auto-generated based on delivery_frequency.';

-- Add column comments
COMMENT ON COLUMN public.contract_deliveries.contract_id IS 'Parent contract';
COMMENT ON COLUMN public.contract_deliveries.expected_date IS 'When this delivery was due';
COMMENT ON COLUMN public.contract_deliveries.actual_date IS 'When the delivery actually happened';
COMMENT ON COLUMN public.contract_deliveries.expected_quantity IS 'Contracted quantity for this delivery';
COMMENT ON COLUMN public.contract_deliveries.actual_quantity IS 'Actual quantity delivered';
COMMENT ON COLUMN public.contract_deliveries.status IS 'Delivery state: upcoming -> due -> delivered -> confirmed/missed';
COMMENT ON COLUMN public.contract_deliveries.farmer_notes IS 'Farmer notes on this delivery';
COMMENT ON COLUMN public.contract_deliveries.store_notes IS 'Store notes on receipt';
COMMENT ON COLUMN public.contract_deliveries.quality_rating IS 'Store rates quality (1-5)';
COMMENT ON COLUMN public.contract_deliveries.order_id IS 'Link to the order created for this delivery';
