-- Migration: Create product_varieties table
-- Description: Optional variety-level detail within a product. E.g., Tomatoes -> Roma, Cherry, Beef.

CREATE TABLE public.product_varieties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- No duplicate variety names within a product
    CONSTRAINT uq_product_varieties_product_name UNIQUE (product_id, name)
);

-- Add table comment
COMMENT ON TABLE public.product_varieties IS 'Optional variety-level detail. E.g., Tomatoes can have Roma, Cherry, Beef varieties.';

-- Add column comments
COMMENT ON COLUMN public.product_varieties.product_id IS 'Parent product';
COMMENT ON COLUMN public.product_varieties.name IS 'Variety name (e.g., Roma, Cherry)';
COMMENT ON COLUMN public.product_varieties.is_active IS 'Soft delete / hide variety';
