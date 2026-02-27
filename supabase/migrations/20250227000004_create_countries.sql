-- Migration: Create countries table
-- Description: Countries the platform operates in. Links stores and farmers to a country and default currency.

CREATE TABLE public.countries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(2) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    currency_id UUID NOT NULL REFERENCES public.currencies(id) ON DELETE RESTRICT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add table comment
COMMENT ON TABLE public.countries IS 'Countries where the platform operates. Each country links to a default currency.';

-- Add column comments
COMMENT ON COLUMN public.countries.code IS 'ISO 3166-1 alpha-2 country code (e.g., BW, ZA)';
COMMENT ON COLUMN public.countries.name IS 'Full country name (e.g., Botswana)';
COMMENT ON COLUMN public.countries.currency_id IS 'Default currency for this country';
COMMENT ON COLUMN public.countries.is_active IS 'Whether the platform operates in this country';
