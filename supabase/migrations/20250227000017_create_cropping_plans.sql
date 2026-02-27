-- Migration: Create cropping_plans table
-- Description: Farmer's planting and growth records. Provides forward visibility for stores.

CREATE TABLE public.cropping_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES public.farmers(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    variety_id UUID REFERENCES public.product_varieties(id) ON DELETE SET NULL,
    date_planted DATE NOT NULL,
    expected_harvest_date DATE NOT NULL,
    estimated_yield DECIMAL(12,2),
    yield_unit_id UUID REFERENCES public.units_of_measure(id) ON DELETE SET NULL,
    actual_yield DECIMAL(12,2),
    growing_status VARCHAR(30) NOT NULL DEFAULT 'planted',
    is_contracted BOOLEAN NOT NULL DEFAULT FALSE,
    contract_id UUID, -- FK added after contracts table exists
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Valid growing statuses
    CONSTRAINT chk_cropping_plans_growing_status CHECK (
        growing_status IN ('planted', 'growing', 'approaching_harvest', 'ready', 'harvested')
    ),

    -- Harvest date must be after planting date
    CONSTRAINT chk_cropping_plans_dates CHECK (
        expected_harvest_date >= date_planted
    )
);

-- Add table comment
COMMENT ON TABLE public.cropping_plans IS 'Farmer planting records providing forward visibility for stores. Contracted plans link to contracts.';

-- Add column comments
COMMENT ON COLUMN public.cropping_plans.farmer_id IS 'Farmer who owns this plan';
COMMENT ON COLUMN public.cropping_plans.product_id IS 'What is being grown';
COMMENT ON COLUMN public.cropping_plans.variety_id IS 'Specific variety (optional)';
COMMENT ON COLUMN public.cropping_plans.date_planted IS 'When the crop was planted';
COMMENT ON COLUMN public.cropping_plans.expected_harvest_date IS 'When harvest is expected';
COMMENT ON COLUMN public.cropping_plans.estimated_yield IS 'Expected quantity';
COMMENT ON COLUMN public.cropping_plans.yield_unit_id IS 'Unit for estimated yield';
COMMENT ON COLUMN public.cropping_plans.actual_yield IS 'Actual quantity harvested (filled after harvest)';
COMMENT ON COLUMN public.cropping_plans.growing_status IS 'Current growth stage';
COMMENT ON COLUMN public.cropping_plans.is_contracted IS 'Whether this crop is committed to a contract';
COMMENT ON COLUMN public.cropping_plans.contract_id IS 'Link to contract if committed';
