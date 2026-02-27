-- Migration: Create contracts table
-- Description: Contract farming agreements between a store and a farmer.

CREATE TABLE public.contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
    farmer_id UUID REFERENCES public.farmers(id) ON DELETE SET NULL,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    variety_id UUID REFERENCES public.product_varieties(id) ON DELETE SET NULL,
    quantity_per_delivery DECIMAL(12,2) NOT NULL,
    unit_id UUID NOT NULL REFERENCES public.units_of_measure(id) ON DELETE RESTRICT,
    price_per_unit DECIMAL(12,2) NOT NULL,
    currency_code VARCHAR(3) NOT NULL DEFAULT 'BWP',
    delivery_frequency VARCHAR(20) NOT NULL,
    custom_frequency_days INTEGER,
    quality_standards TEXT,
    payment_terms VARCHAR(50),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_contracted_qty DECIMAL(12,2),
    total_delivered_qty DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fulfillment_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'open',
    is_public BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Valid delivery frequencies
    CONSTRAINT chk_contracts_delivery_frequency CHECK (
        delivery_frequency IN ('weekly', 'biweekly', 'monthly', 'custom')
    ),

    -- Valid statuses
    CONSTRAINT chk_contracts_status CHECK (
        status IN ('open', 'accepted', 'active', 'completed', 'cancelled')
    ),

    -- Valid payment terms
    CONSTRAINT chk_contracts_payment_terms CHECK (
        payment_terms IS NULL OR payment_terms IN ('on_delivery', 'weekly', 'monthly')
    ),

    -- End date must be after start date
    CONSTRAINT chk_contracts_dates CHECK (
        end_date >= start_date
    ),

    -- Custom frequency days required when delivery_frequency is 'custom'
    CONSTRAINT chk_contracts_custom_frequency CHECK (
        delivery_frequency != 'custom' OR custom_frequency_days IS NOT NULL
    )
);

-- Add table comment
COMMENT ON TABLE public.contracts IS 'Contract farming agreements. farmer_id is NULL until a farmer accepts (open status).';

-- Add column comments
COMMENT ON COLUMN public.contracts.store_id IS 'Store offering the contract';
COMMENT ON COLUMN public.contracts.farmer_id IS 'Farmer (NULL until accepted)';
COMMENT ON COLUMN public.contracts.product_id IS 'Contracted crop';
COMMENT ON COLUMN public.contracts.variety_id IS 'Specific variety (optional)';
COMMENT ON COLUMN public.contracts.quantity_per_delivery IS 'Required quantity per delivery cycle';
COMMENT ON COLUMN public.contracts.unit_id IS 'Unit of measure';
COMMENT ON COLUMN public.contracts.price_per_unit IS 'Agreed price per unit (fixed for duration)';
COMMENT ON COLUMN public.contracts.currency_code IS 'Currency ISO 4217 code';
COMMENT ON COLUMN public.contracts.delivery_frequency IS 'weekly, biweekly, monthly, or custom';
COMMENT ON COLUMN public.contracts.custom_frequency_days IS 'If custom, number of days between deliveries';
COMMENT ON COLUMN public.contracts.quality_standards IS 'Quality requirements';
COMMENT ON COLUMN public.contracts.payment_terms IS 'When payment is due';
COMMENT ON COLUMN public.contracts.start_date IS 'Contract start';
COMMENT ON COLUMN public.contracts.end_date IS 'Contract end';
COMMENT ON COLUMN public.contracts.total_contracted_qty IS 'Calculated total over contract period';
COMMENT ON COLUMN public.contracts.total_delivered_qty IS 'Running total of all deliveries';
COMMENT ON COLUMN public.contracts.fulfillment_rate IS 'Percentage of contracted volume delivered';
COMMENT ON COLUMN public.contracts.status IS 'Contract state flow: open -> accepted -> active -> completed/cancelled';
COMMENT ON COLUMN public.contracts.is_public IS 'TRUE = visible to all eligible farmers, FALSE = sent to specific farmer';

-- Add FK from cropping_plans.contract_id to contracts.id now that contracts table exists
ALTER TABLE public.cropping_plans
    ADD CONSTRAINT fk_cropping_plans_contract
    FOREIGN KEY (contract_id) REFERENCES public.contracts(id) ON DELETE SET NULL;
