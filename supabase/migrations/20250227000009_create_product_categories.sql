-- Migration: Create product_categories table
-- Description: Top-level product categories. Managed by admins.

CREATE TABLE public.product_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_url TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add table comment
COMMENT ON TABLE public.product_categories IS 'Top-level product categories (Fruits, Vegetables, Herbs, Leafy Greens). Admin-managed.';

-- Add column comments
COMMENT ON COLUMN public.product_categories.name IS 'Category name (unique)';
COMMENT ON COLUMN public.product_categories.sort_order IS 'Display ordering';
COMMENT ON COLUMN public.product_categories.is_active IS 'Soft delete / hide category';
