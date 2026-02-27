-- Migration: Create product_requests table
-- Description: Farmer requests to add a product not in the catalogue.

CREATE TABLE public.product_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES public.farmers(id) ON DELETE CASCADE,
    product_name VARCHAR(100) NOT NULL,
    suggested_category_id UUID REFERENCES public.product_categories(id) ON DELETE SET NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    admin_notes TEXT,
    reviewed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMPTZ,
    created_product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Valid statuses
    CONSTRAINT chk_product_requests_status CHECK (
        status IN ('pending', 'approved', 'rejected')
    )
);

-- Add table comment
COMMENT ON TABLE public.product_requests IS 'Farmer requests to add new products to the catalog. Admin reviews and approves/rejects.';

-- Add column comments
COMMENT ON COLUMN public.product_requests.farmer_id IS 'Farmer who requested the product';
COMMENT ON COLUMN public.product_requests.product_name IS 'Suggested product name';
COMMENT ON COLUMN public.product_requests.suggested_category_id IS 'Suggested category for the product';
COMMENT ON COLUMN public.product_requests.status IS 'Request status: pending, approved, rejected';
COMMENT ON COLUMN public.product_requests.admin_notes IS 'Admin response or reason for rejection';
COMMENT ON COLUMN public.product_requests.reviewed_by IS 'Admin who reviewed the request';
COMMENT ON COLUMN public.product_requests.created_product_id IS 'If approved, link to the created product';
