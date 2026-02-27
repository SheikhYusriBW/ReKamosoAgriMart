-- Migration: Create stores table
-- Description: Store-specific profile. Extends profiles for users with role = 'store'.

CREATE TABLE public.stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    business_name VARCHAR(255) NOT NULL,
    store_type VARCHAR(50) NOT NULL,
    location_lat DECIMAL(10,7),
    location_lng DECIMAL(10,7),
    address TEXT,
    country_id UUID REFERENCES public.countries(id) ON DELETE SET NULL,
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    bio TEXT,
    logo_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Valid store types
    CONSTRAINT chk_stores_store_type CHECK (
        store_type IN ('grocery', 'depo', 'restaurant', 'hotel', 'other')
    )
);

-- Add table comment
COMMENT ON TABLE public.stores IS 'Store-specific profile for store operators. Links to base profile.';

-- Add column comments
COMMENT ON COLUMN public.stores.profile_id IS 'Link to base profile - unique 1:1 relationship';
COMMENT ON COLUMN public.stores.store_type IS 'Type of store: grocery, depo, restaurant, hotel, or other';
COMMENT ON COLUMN public.stores.country_id IS 'Country where the store is located';
COMMENT ON COLUMN public.stores.contact_phone IS 'Business phone (may differ from profile phone)';
COMMENT ON COLUMN public.stores.is_active IS 'Admin can deactivate stores';
