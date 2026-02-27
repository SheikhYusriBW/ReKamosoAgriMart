-- Migration: Create farmers table
-- Description: Farmer-specific profile and verification data. Extends profiles for users with role = 'farmer'.
-- Includes rating aggregates (denormalized for performance) and verification fields.

CREATE TABLE public.farmers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    farm_name VARCHAR(255) NOT NULL,
    farm_location_lat DECIMAL(10,7),
    farm_location_lng DECIMAL(10,7),
    farm_address TEXT,
    country_id UUID REFERENCES public.countries(id) ON DELETE SET NULL,
    farm_size VARCHAR(100),
    farm_size_unit VARCHAR(20),
    id_number VARCHAR(50),
    bio TEXT,
    verification_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    rejection_reason TEXT,
    verified_at TIMESTAMPTZ,
    verified_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    avg_overall_rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    avg_quality_rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    avg_reliability_rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    total_reviews INTEGER NOT NULL DEFAULT 0,
    total_transactions INTEGER NOT NULL DEFAULT 0,
    contract_fulfillment_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Valid verification statuses
    CONSTRAINT chk_farmers_verification_status CHECK (
        verification_status IN ('pending', 'approved', 'rejected', 'suspended')
    ),

    -- Valid farm size units
    CONSTRAINT chk_farmers_farm_size_unit CHECK (
        farm_size_unit IS NULL OR farm_size_unit IN ('hectares', 'acres', 'sqm')
    )
);

-- Add table comment
COMMENT ON TABLE public.farmers IS 'Farmer-specific profile. Rating fields are denormalized from reviews table for fast display.';

-- Add column comments
COMMENT ON COLUMN public.farmers.profile_id IS 'Link to base profile - unique 1:1 relationship';
COMMENT ON COLUMN public.farmers.verification_status IS 'Gates all farmer actions - only approved farmers can list, bid, or accept contracts';
COMMENT ON COLUMN public.farmers.avg_overall_rating IS 'Aggregate overall rating (1-5), updated via trigger on reviews';
COMMENT ON COLUMN public.farmers.avg_quality_rating IS 'Aggregate quality rating (1-5), updated via trigger';
COMMENT ON COLUMN public.farmers.avg_reliability_rating IS 'Aggregate reliability rating (1-5), updated via trigger';
COMMENT ON COLUMN public.farmers.total_reviews IS 'Total number of reviews received';
COMMENT ON COLUMN public.farmers.total_transactions IS 'Total completed orders';
COMMENT ON COLUMN public.farmers.contract_fulfillment_rate IS 'Percentage of contracted volume delivered on time';
COMMENT ON COLUMN public.farmers.country_id IS 'Country where the farm is located';
