-- Migration: Create products table
-- Description: Individual products within categories. Managed by admins. Farmers select from this list.

CREATE TABLE public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES public.product_categories(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- No duplicate product names within a category
    CONSTRAINT uq_products_category_name UNIQUE (category_id, name)
);

-- Add table comment
COMMENT ON TABLE public.products IS 'Individual products within categories. Farmers select from this catalog when creating listings.';

-- Add column comments
COMMENT ON COLUMN public.products.category_id IS 'Parent category';
COMMENT ON COLUMN public.products.name IS 'Product name (e.g., Tomatoes, Spinach)';
COMMENT ON COLUMN public.products.image_url IS 'Default product image';
COMMENT ON COLUMN public.products.sort_order IS 'Display ordering within category';
COMMENT ON COLUMN public.products.is_active IS 'Soft delete / hide product';
