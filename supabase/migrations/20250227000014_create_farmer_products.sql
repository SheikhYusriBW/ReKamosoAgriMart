-- Migration: Create farmer_products table
-- Description: Links a farmer to the products they grow. Used for matching tenders, contracts, and filtering.

CREATE TABLE public.farmer_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES public.farmers(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- A farmer can only link to a product once
    CONSTRAINT uq_farmer_products_farmer_product UNIQUE (farmer_id, product_id)
);

-- Add table comment
COMMENT ON TABLE public.farmer_products IS 'Links farmers to products they grow. Used for tender matching and filtering.';

-- Add column comments
COMMENT ON COLUMN public.farmer_products.farmer_id IS 'The farmer';
COMMENT ON COLUMN public.farmer_products.product_id IS 'Product the farmer grows';
