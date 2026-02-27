-- Migration: Create order_items table
-- Description: Line items within an order. An order can contain multiple products.

CREATE TABLE public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    variety_id UUID REFERENCES public.product_varieties(id) ON DELETE SET NULL,
    quantity DECIMAL(12,2) NOT NULL,
    unit_id UUID NOT NULL REFERENCES public.units_of_measure(id) ON DELETE RESTRICT,
    price_per_unit DECIMAL(12,2) NOT NULL,
    currency_code VARCHAR(3) NOT NULL DEFAULT 'BWP',
    line_total DECIMAL(12,2) NOT NULL,
    actual_qty_received DECIMAL(12,2),
    quality_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add table comment
COMMENT ON TABLE public.order_items IS 'Line items within an order. Supports multi-product orders.';

-- Add column comments
COMMENT ON COLUMN public.order_items.order_id IS 'Parent order';
COMMENT ON COLUMN public.order_items.product_id IS 'Product';
COMMENT ON COLUMN public.order_items.variety_id IS 'Variety (optional)';
COMMENT ON COLUMN public.order_items.quantity IS 'Ordered quantity';
COMMENT ON COLUMN public.order_items.unit_id IS 'Unit of measure';
COMMENT ON COLUMN public.order_items.price_per_unit IS 'Agreed price per unit';
COMMENT ON COLUMN public.order_items.currency_code IS 'Currency ISO 4217 code';
COMMENT ON COLUMN public.order_items.line_total IS 'quantity x price_per_unit';
COMMENT ON COLUMN public.order_items.actual_qty_received IS 'What the store actually received';
COMMENT ON COLUMN public.order_items.quality_notes IS 'Store notes on quality of this item';
