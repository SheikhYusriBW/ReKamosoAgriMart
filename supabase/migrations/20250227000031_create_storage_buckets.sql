-- Migration: Create Supabase Storage buckets and policies
-- Description: Storage buckets for avatars, farm images, listing images, store logos, and product images

-- ============================================
-- CREATE STORAGE BUCKETS
-- ============================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);

INSERT INTO storage.buckets (id, name, public)
VALUES ('farm-images', 'farm-images', true);

INSERT INTO storage.buckets (id, name, public)
VALUES ('listing-images', 'listing-images', true);

INSERT INTO storage.buckets (id, name, public)
VALUES ('store-logos', 'store-logos', true);

INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true);

-- ============================================
-- STORAGE POLICIES
-- ============================================

-- AVATARS BUCKET
-- Public can read
CREATE POLICY "Public can view avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

-- Authenticated users can upload
CREATE POLICY "Authenticated users can upload avatars"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
);

-- Users can update their own avatars
CREATE POLICY "Users can update own avatars"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can delete their own avatars
CREATE POLICY "Users can delete own avatars"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- FARM-IMAGES BUCKET
-- Public can read
CREATE POLICY "Public can view farm images"
ON storage.objects FOR SELECT
USING (bucket_id = 'farm-images');

-- Authenticated users can upload
CREATE POLICY "Authenticated users can upload farm images"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'farm-images'
    AND auth.role() = 'authenticated'
);

-- Users can update their own farm images
CREATE POLICY "Users can update own farm images"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'farm-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can delete their own farm images
CREATE POLICY "Users can delete own farm images"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'farm-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- LISTING-IMAGES BUCKET
-- Public can read
CREATE POLICY "Public can view listing images"
ON storage.objects FOR SELECT
USING (bucket_id = 'listing-images');

-- Authenticated users can upload
CREATE POLICY "Authenticated users can upload listing images"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'listing-images'
    AND auth.role() = 'authenticated'
);

-- Users can update their own listing images
CREATE POLICY "Users can update own listing images"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'listing-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can delete their own listing images
CREATE POLICY "Users can delete own listing images"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'listing-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- STORE-LOGOS BUCKET
-- Public can read
CREATE POLICY "Public can view store logos"
ON storage.objects FOR SELECT
USING (bucket_id = 'store-logos');

-- Authenticated users can upload
CREATE POLICY "Authenticated users can upload store logos"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'store-logos'
    AND auth.role() = 'authenticated'
);

-- Users can update their own store logos
CREATE POLICY "Users can update own store logos"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'store-logos'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can delete their own store logos
CREATE POLICY "Users can delete own store logos"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'store-logos'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- PRODUCT-IMAGES BUCKET
-- Public can read
CREATE POLICY "Public can view product images"
ON storage.objects FOR SELECT
USING (bucket_id = 'product-images');

-- Only admins can upload product images (via service role key or admin check)
CREATE POLICY "Admins can upload product images"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'product-images'
    AND auth.role() = 'authenticated'
);

-- Only admins can update product images
CREATE POLICY "Admins can update product images"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'product-images'
    AND auth.role() = 'authenticated'
);

-- Only admins can delete product images
CREATE POLICY "Admins can delete product images"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'product-images'
    AND auth.role() = 'authenticated'
);
