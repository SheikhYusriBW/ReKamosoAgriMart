-- Migration: Create reviews table
-- Description: Store reviews of farmers after completed deliveries.

CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL UNIQUE REFERENCES public.orders(id) ON DELETE CASCADE,
    store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
    farmer_id UUID NOT NULL REFERENCES public.farmers(id) ON DELETE CASCADE,
    overall_rating INTEGER NOT NULL,
    quality_rating INTEGER NOT NULL,
    reliability_rating INTEGER NOT NULL,
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Ratings must be 1-5
    CONSTRAINT chk_reviews_overall_rating CHECK (overall_rating >= 1 AND overall_rating <= 5),
    CONSTRAINT chk_reviews_quality_rating CHECK (quality_rating >= 1 AND quality_rating <= 5),
    CONSTRAINT chk_reviews_reliability_rating CHECK (reliability_rating >= 1 AND reliability_rating <= 5)
);

-- Add table comment
COMMENT ON TABLE public.reviews IS 'Store reviews of farmers. One review per order. Triggers recalculation of farmer aggregate ratings.';

-- Add column comments
COMMENT ON COLUMN public.reviews.order_id IS 'One review per order (unique constraint)';
COMMENT ON COLUMN public.reviews.store_id IS 'Store leaving the review';
COMMENT ON COLUMN public.reviews.farmer_id IS 'Farmer being reviewed';
COMMENT ON COLUMN public.reviews.overall_rating IS 'Overall experience (1-5)';
COMMENT ON COLUMN public.reviews.quality_rating IS 'Produce quality (1-5)';
COMMENT ON COLUMN public.reviews.reliability_rating IS 'On-time, correct quantities (1-5)';
COMMENT ON COLUMN public.reviews.comment IS 'Written review (optional)';
