-- Migration: Create listing_images table
-- Description: Photos attached to a listing.

CREATE TABLE public.listing_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add table comment
COMMENT ON TABLE public.listing_images IS 'Photos attached to listings. Publicly viewable.';

-- Add column comments
COMMENT ON COLUMN public.listing_images.listing_id IS 'Parent listing';
COMMENT ON COLUMN public.listing_images.image_url IS 'Supabase Storage URL';
COMMENT ON COLUMN public.listing_images.sort_order IS 'Display ordering';
