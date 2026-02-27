-- Migration: Create farm_images table
-- Description: Photos of the farm uploaded during registration or later.

CREATE TABLE public.farm_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES public.farmers(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add table comment
COMMENT ON TABLE public.farm_images IS 'Farm photos uploaded by farmers. Used for verification and profile display.';

-- Add column comments
COMMENT ON COLUMN public.farm_images.farmer_id IS 'The farmer who owns this farm';
COMMENT ON COLUMN public.farm_images.image_url IS 'Supabase Storage URL for the image';
COMMENT ON COLUMN public.farm_images.is_primary IS 'Primary display image for the farm';
