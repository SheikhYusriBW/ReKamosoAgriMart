-- Migration: Create currencies table
-- Description: Supported currencies on the platform. Allows multi-country expansion without code changes.

CREATE TABLE public.currencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(3) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    symbol VARCHAR(10) NOT NULL,
    decimal_precision INTEGER NOT NULL DEFAULT 2,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add table comment
COMMENT ON TABLE public.currencies IS 'Supported currencies for multi-country support. BWP is default, ZAR seeded for future SA expansion.';

-- Add column comments
COMMENT ON COLUMN public.currencies.code IS 'ISO 4217 currency code (e.g., BWP, ZAR)';
COMMENT ON COLUMN public.currencies.name IS 'Full currency name (e.g., Botswana Pula)';
COMMENT ON COLUMN public.currencies.symbol IS 'Display symbol (e.g., P, R)';
COMMENT ON COLUMN public.currencies.decimal_precision IS 'Decimal places for this currency (2 for most)';
COMMENT ON COLUMN public.currencies.is_active IS 'Whether this currency is available for use';
