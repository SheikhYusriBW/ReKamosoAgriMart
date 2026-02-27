-- Migration: Create units_of_measure table
-- Description: Standardized units. Stored as a table so admins can add/edit without code changes.

CREATE TABLE public.units_of_measure (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL UNIQUE,
    abbreviation VARCHAR(10) NOT NULL UNIQUE,
    context VARCHAR(20) NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Valid contexts
    CONSTRAINT chk_units_of_measure_context CHECK (
        context IN ('farmer_to_store', 'store_to_consumer', 'both')
    )
);

-- Add table comment
COMMENT ON TABLE public.units_of_measure IS 'Standardized units for quantities. Context determines where each unit is used.';

-- Add column comments
COMMENT ON COLUMN public.units_of_measure.name IS 'Full name (e.g., Kilogram, Tonne)';
COMMENT ON COLUMN public.units_of_measure.abbreviation IS 'Short form (e.g., kg, t)';
COMMENT ON COLUMN public.units_of_measure.context IS 'Where this unit is used: farmer_to_store, store_to_consumer, or both';
COMMENT ON COLUMN public.units_of_measure.sort_order IS 'Display ordering';
COMMENT ON COLUMN public.units_of_measure.is_active IS 'Soft delete / hide unit';
