-- Migration: Create orders table
-- Description: All orders regardless of source (spot market, tender, contract). Central transaction table.

-- Create sequence for order numbers
CREATE SEQUENCE public.order_number_seq START 1;

CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(20) NOT NULL UNIQUE,
    store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
    farmer_id UUID NOT NULL REFERENCES public.farmers(id) ON DELETE CASCADE,
    source VARCHAR(20) NOT NULL,
    listing_id UUID REFERENCES public.listings(id) ON DELETE SET NULL,
    tender_offer_id UUID REFERENCES public.tender_offers(id) ON DELETE SET NULL,
    contract_delivery_id UUID REFERENCES public.contract_deliveries(id) ON DELETE SET NULL,
    delivery_method VARCHAR(20) NOT NULL,
    delivery_date DATE,
    delivery_address TEXT,
    pickup_address TEXT,
    subtotal DECIMAL(12,2) NOT NULL,
    currency_code VARCHAR(3) NOT NULL DEFAULT 'BWP',
    commission_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    commission_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'new',
    payment_status VARCHAR(20) NOT NULL DEFAULT 'unpaid',
    payment_method VARCHAR(20),
    actual_qty_received DECIMAL(12,2),
    store_notes TEXT,
    farmer_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Valid sources
    CONSTRAINT chk_orders_source CHECK (
        source IN ('spot', 'tender', 'contract')
    ),

    -- Valid delivery methods
    CONSTRAINT chk_orders_delivery_method CHECK (
        delivery_method IN ('farmer_delivers', 'store_collects', 'third_party')
    ),

    -- Valid statuses
    CONSTRAINT chk_orders_status CHECK (
        status IN ('new', 'accepted', 'preparing', 'ready', 'in_transit', 'delivered', 'confirmed', 'cancelled')
    ),

    -- Valid payment statuses
    CONSTRAINT chk_orders_payment_status CHECK (
        payment_status IN ('unpaid', 'paid', 'confirmed')
    ),

    -- Valid payment methods
    CONSTRAINT chk_orders_payment_method CHECK (
        payment_method IS NULL OR payment_method IN ('cash', 'eft')
    )
);

-- Function to auto-generate order numbers
CREATE OR REPLACE FUNCTION public.generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_number := 'ORD-' || LPAD(NEXTVAL('public.order_number_seq')::TEXT, 5, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to set order number on insert
CREATE TRIGGER set_order_number
    BEFORE INSERT ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.generate_order_number();

-- Add table comment
COMMENT ON TABLE public.orders IS 'Central transaction table. Source links to listing, tender_offer, or contract_delivery.';

-- Add column comments
COMMENT ON COLUMN public.orders.order_number IS 'Human-readable order number (e.g., ORD-00001)';
COMMENT ON COLUMN public.orders.store_id IS 'Store placing the order';
COMMENT ON COLUMN public.orders.farmer_id IS 'Farmer fulfilling the order';
COMMENT ON COLUMN public.orders.source IS 'Where this order originated: spot, tender, or contract';
COMMENT ON COLUMN public.orders.listing_id IS 'If source = spot, the listing (SET NULL on delete to preserve history)';
COMMENT ON COLUMN public.orders.tender_offer_id IS 'If source = tender, the accepted offer (SET NULL on delete)';
COMMENT ON COLUMN public.orders.contract_delivery_id IS 'If source = contract, the delivery (SET NULL on delete)';
COMMENT ON COLUMN public.orders.delivery_method IS 'Who handles delivery';
COMMENT ON COLUMN public.orders.delivery_date IS 'Expected delivery/collection date';
COMMENT ON COLUMN public.orders.delivery_address IS 'Delivery destination if farmer delivers';
COMMENT ON COLUMN public.orders.pickup_address IS 'Pickup location if store collects';
COMMENT ON COLUMN public.orders.subtotal IS 'Total value of order items';
COMMENT ON COLUMN public.orders.currency_code IS 'Currency ISO 4217 code';
COMMENT ON COLUMN public.orders.commission_rate IS 'Commission % at time of order (snapshot)';
COMMENT ON COLUMN public.orders.commission_amount IS 'Calculated commission amount';
COMMENT ON COLUMN public.orders.status IS 'Order status flow: new -> accepted -> preparing -> ready -> in_transit -> delivered -> confirmed';
COMMENT ON COLUMN public.orders.payment_status IS 'Payment status: unpaid -> paid -> confirmed';
COMMENT ON COLUMN public.orders.payment_method IS 'How payment was made';
COMMENT ON COLUMN public.orders.actual_qty_received IS 'Actual total quantity store received';

-- Add FK from contract_deliveries.order_id to orders.id now that orders table exists
ALTER TABLE public.contract_deliveries
    ADD CONSTRAINT fk_contract_deliveries_order
    FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE SET NULL;
