-- Seed data for ReKamoso AgriMart
-- This file populates initial reference data for the platform
-- Run after migrations with: supabase db reset (runs migrations + seed)

-- ============================================
-- CURRENCIES
-- ============================================
INSERT INTO public.currencies (id, code, name, symbol, decimal_precision, is_active)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'BWP', 'Botswana Pula', 'P', 2, true),
    ('22222222-2222-2222-2222-222222222222', 'ZAR', 'South African Rand', 'R', 2, false);

-- ============================================
-- COUNTRIES
-- ============================================
INSERT INTO public.countries (id, code, name, currency_id, is_active)
VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'BW', 'Botswana', '11111111-1111-1111-1111-111111111111', true),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'ZA', 'South Africa', '22222222-2222-2222-2222-222222222222', false);

-- ============================================
-- PRODUCT CATEGORIES
-- ============================================
INSERT INTO public.product_categories (id, name, description, sort_order, is_active)
VALUES
    ('cccccccc-0001-0001-0001-cccccccccccc', 'Fruits', 'Fresh fruits from local farms', 1, true),
    ('cccccccc-0002-0002-0002-cccccccccccc', 'Vegetables', 'Fresh vegetables from local farms', 2, true),
    ('cccccccc-0003-0003-0003-cccccccccccc', 'Herbs', 'Fresh culinary and medicinal herbs', 3, true),
    ('cccccccc-0004-0004-0004-cccccccccccc', 'Leafy Greens', 'Fresh leafy green vegetables', 4, true);

-- ============================================
-- PRODUCTS
-- ============================================

-- Fruits (category: cccccccc-0001-0001-0001-cccccccccccc)
INSERT INTO public.products (id, category_id, name, sort_order, is_active)
VALUES
    ('dddddddd-0001-0001-0001-dddddddddddd', 'cccccccc-0001-0001-0001-cccccccccccc', 'Tomatoes', 1, true),
    ('dddddddd-0002-0001-0001-dddddddddddd', 'cccccccc-0001-0001-0001-cccccccccccc', 'Apples', 2, true),
    ('dddddddd-0003-0001-0001-dddddddddddd', 'cccccccc-0001-0001-0001-cccccccccccc', 'Oranges', 3, true),
    ('dddddddd-0004-0001-0001-dddddddddddd', 'cccccccc-0001-0001-0001-cccccccccccc', 'Bananas', 4, true),
    ('dddddddd-0005-0001-0001-dddddddddddd', 'cccccccc-0001-0001-0001-cccccccccccc', 'Grapes', 5, true),
    ('dddddddd-0006-0001-0001-dddddddddddd', 'cccccccc-0001-0001-0001-cccccccccccc', 'Mangoes', 6, true),
    ('dddddddd-0007-0001-0001-dddddddddddd', 'cccccccc-0001-0001-0001-cccccccccccc', 'Avocados', 7, true),
    ('dddddddd-0008-0001-0001-dddddddddddd', 'cccccccc-0001-0001-0001-cccccccccccc', 'Peaches', 8, true),
    ('dddddddd-0009-0001-0001-dddddddddddd', 'cccccccc-0001-0001-0001-cccccccccccc', 'Berries', 9, true),
    ('dddddddd-0010-0001-0001-dddddddddddd', 'cccccccc-0001-0001-0001-cccccccccccc', 'Watermelon', 10, true),
    ('dddddddd-0011-0001-0001-dddddddddddd', 'cccccccc-0001-0001-0001-cccccccccccc', 'Lemons', 11, true);

-- Vegetables (category: cccccccc-0002-0002-0002-cccccccccccc)
INSERT INTO public.products (id, category_id, name, sort_order, is_active)
VALUES
    ('dddddddd-0001-0002-0002-dddddddddddd', 'cccccccc-0002-0002-0002-cccccccccccc', 'Cabbage', 1, true),
    ('dddddddd-0002-0002-0002-dddddddddddd', 'cccccccc-0002-0002-0002-cccccccccccc', 'Onions', 2, true),
    ('dddddddd-0003-0002-0002-dddddddddddd', 'cccccccc-0002-0002-0002-cccccccccccc', 'Potatoes', 3, true),
    ('dddddddd-0004-0002-0002-dddddddddddd', 'cccccccc-0002-0002-0002-cccccccccccc', 'Butternut', 4, true),
    ('dddddddd-0005-0002-0002-dddddddddddd', 'cccccccc-0002-0002-0002-cccccccccccc', 'Carrots', 5, true),
    ('dddddddd-0006-0002-0002-dddddddddddd', 'cccccccc-0002-0002-0002-cccccccccccc', 'Green Beans', 6, true),
    ('dddddddd-0007-0002-0002-dddddddddddd', 'cccccccc-0002-0002-0002-cccccccccccc', 'Peppers', 7, true),
    ('dddddddd-0008-0002-0002-dddddddddddd', 'cccccccc-0002-0002-0002-cccccccccccc', 'Broccoli', 8, true),
    ('dddddddd-0009-0002-0002-dddddddddddd', 'cccccccc-0002-0002-0002-cccccccccccc', 'Lettuce', 9, true),
    ('dddddddd-0010-0002-0002-dddddddddddd', 'cccccccc-0002-0002-0002-cccccccccccc', 'Beetroot', 10, true);

-- Herbs (category: cccccccc-0003-0003-0003-cccccccccccc)
INSERT INTO public.products (id, category_id, name, sort_order, is_active)
VALUES
    ('dddddddd-0001-0003-0003-dddddddddddd', 'cccccccc-0003-0003-0003-cccccccccccc', 'Parsley', 1, true),
    ('dddddddd-0002-0003-0003-dddddddddddd', 'cccccccc-0003-0003-0003-cccccccccccc', 'Coriander', 2, true),
    ('dddddddd-0003-0003-0003-dddddddddddd', 'cccccccc-0003-0003-0003-cccccccccccc', 'Basil', 3, true),
    ('dddddddd-0004-0003-0003-dddddddddddd', 'cccccccc-0003-0003-0003-cccccccccccc', 'Mint', 4, true),
    ('dddddddd-0005-0003-0003-dddddddddddd', 'cccccccc-0003-0003-0003-cccccccccccc', 'Rosemary', 5, true);

-- Leafy Greens (category: cccccccc-0004-0004-0004-cccccccccccc)
INSERT INTO public.products (id, category_id, name, sort_order, is_active)
VALUES
    ('dddddddd-0001-0004-0004-dddddddddddd', 'cccccccc-0004-0004-0004-cccccccccccc', 'Spinach', 1, true),
    ('dddddddd-0002-0004-0004-dddddddddddd', 'cccccccc-0004-0004-0004-cccccccccccc', 'Kale', 2, true),
    ('dddddddd-0003-0004-0004-dddddddddddd', 'cccccccc-0004-0004-0004-cccccccccccc', 'Swiss Chard', 3, true),
    ('dddddddd-0004-0004-0004-dddddddddddd', 'cccccccc-0004-0004-0004-cccccccccccc', 'Rocket', 4, true),
    ('dddddddd-0005-0004-0004-dddddddddddd', 'cccccccc-0004-0004-0004-cccccccccccc', 'Baby Spinach', 5, true);

-- ============================================
-- PRODUCT VARIETIES
-- ============================================

-- Tomatoes varieties
INSERT INTO public.product_varieties (id, product_id, name, is_active)
VALUES
    ('eeeeeeee-0001-0001-0001-eeeeeeeeeeee', 'dddddddd-0001-0001-0001-dddddddddddd', 'Roma', true),
    ('eeeeeeee-0002-0001-0001-eeeeeeeeeeee', 'dddddddd-0001-0001-0001-dddddddddddd', 'Cherry', true),
    ('eeeeeeee-0003-0001-0001-eeeeeeeeeeee', 'dddddddd-0001-0001-0001-dddddddddddd', 'Beef', true),
    ('eeeeeeee-0004-0001-0001-eeeeeeeeeeee', 'dddddddd-0001-0001-0001-dddddddddddd', 'Grape', true);

-- Peppers varieties
INSERT INTO public.product_varieties (id, product_id, name, is_active)
VALUES
    ('eeeeeeee-0001-0007-0002-eeeeeeeeeeee', 'dddddddd-0007-0002-0002-dddddddddddd', 'Green', true),
    ('eeeeeeee-0002-0007-0002-eeeeeeeeeeee', 'dddddddd-0007-0002-0002-dddddddddddd', 'Red', true),
    ('eeeeeeee-0003-0007-0002-eeeeeeeeeeee', 'dddddddd-0007-0002-0002-dddddddddddd', 'Yellow', true),
    ('eeeeeeee-0004-0007-0002-eeeeeeeeeeee', 'dddddddd-0007-0002-0002-dddddddddddd', 'Chilli', true);

-- Onions varieties
INSERT INTO public.product_varieties (id, product_id, name, is_active)
VALUES
    ('eeeeeeee-0001-0002-0002-eeeeeeeeeeee', 'dddddddd-0002-0002-0002-dddddddddddd', 'Red', true),
    ('eeeeeeee-0002-0002-0002-eeeeeeeeeeee', 'dddddddd-0002-0002-0002-dddddddddddd', 'White', true),
    ('eeeeeeee-0003-0002-0002-eeeeeeeeeeee', 'dddddddd-0002-0002-0002-dddddddddddd', 'Spring', true);

-- Potatoes varieties
INSERT INTO public.product_varieties (id, product_id, name, is_active)
VALUES
    ('eeeeeeee-0001-0003-0002-eeeeeeeeeeee', 'dddddddd-0003-0002-0002-dddddddddddd', 'Russet', true),
    ('eeeeeeee-0002-0003-0002-eeeeeeeeeeee', 'dddddddd-0003-0002-0002-dddddddddddd', 'Sweet', true),
    ('eeeeeeee-0003-0003-0002-eeeeeeeeeeee', 'dddddddd-0003-0002-0002-dddddddddddd', 'Baby', true);

-- Apples varieties
INSERT INTO public.product_varieties (id, product_id, name, is_active)
VALUES
    ('eeeeeeee-0001-0002-0001-eeeeeeeeeeee', 'dddddddd-0002-0001-0001-dddddddddddd', 'Granny Smith', true),
    ('eeeeeeee-0002-0002-0001-eeeeeeeeeeee', 'dddddddd-0002-0001-0001-dddddddddddd', 'Fuji', true),
    ('eeeeeeee-0003-0002-0001-eeeeeeeeeeee', 'dddddddd-0002-0001-0001-dddddddddddd', 'Golden Delicious', true);

-- Oranges varieties
INSERT INTO public.product_varieties (id, product_id, name, is_active)
VALUES
    ('eeeeeeee-0001-0003-0001-eeeeeeeeeeee', 'dddddddd-0003-0001-0001-dddddddddddd', 'Navel', true),
    ('eeeeeeee-0002-0003-0001-eeeeeeeeeeee', 'dddddddd-0003-0001-0001-dddddddddddd', 'Valencia', true);

-- Bananas varieties
INSERT INTO public.product_varieties (id, product_id, name, is_active)
VALUES
    ('eeeeeeee-0001-0004-0001-eeeeeeeeeeee', 'dddddddd-0004-0001-0001-dddddddddddd', 'Cavendish', true),
    ('eeeeeeee-0002-0004-0001-eeeeeeeeeeee', 'dddddddd-0004-0001-0001-dddddddddddd', 'Lady Finger', true);

-- Basil varieties
INSERT INTO public.product_varieties (id, product_id, name, is_active)
VALUES
    ('eeeeeeee-0001-0003-0003-eeeeeeeeeeee', 'dddddddd-0003-0003-0003-dddddddddddd', 'Sweet', true),
    ('eeeeeeee-0002-0003-0003-eeeeeeeeeeee', 'dddddddd-0003-0003-0003-dddddddddddd', 'Thai', true),
    ('eeeeeeee-0003-0003-0003-eeeeeeeeeeee', 'dddddddd-0003-0003-0003-dddddddddddd', 'Purple', true);

-- ============================================
-- UNITS OF MEASURE
-- ============================================
INSERT INTO public.units_of_measure (id, name, abbreviation, context, sort_order, is_active)
VALUES
    ('ffffffff-0001-0001-0001-ffffffffffff', 'Kilogram', 'kg', 'both', 1, true),
    ('ffffffff-0002-0002-0002-ffffffffffff', 'Tonne', 't', 'farmer_to_store', 2, true),
    ('ffffffff-0003-0003-0003-ffffffffffff', 'Crate', 'crate', 'farmer_to_store', 3, true),
    ('ffffffff-0004-0004-0004-ffffffffffff', 'Bunch', 'bunch', 'both', 4, true),
    ('ffffffff-0005-0005-0005-ffffffffffff', 'Bag', 'bag', 'farmer_to_store', 5, true),
    ('ffffffff-0006-0006-0006-ffffffffffff', 'Each', 'each', 'both', 6, true),
    ('ffffffff-0007-0007-0007-ffffffffffff', 'Gram', 'g', 'store_to_consumer', 7, true),
    ('ffffffff-0008-0008-0008-ffffffffffff', 'Pack', 'pack', 'store_to_consumer', 8, true);

-- ============================================
-- PLATFORM SETTINGS
-- ============================================
INSERT INTO public.platform_settings (id, key, value, description)
VALUES
    (gen_random_uuid(), 'commission_rate', '0', 'Commission percentage (0-100). TBD.'),
    (gen_random_uuid(), 'platform_name', 'ReKamoso AgriMart', 'Platform display name'),
    (gen_random_uuid(), 'support_phone', '', 'Platform support phone number'),
    (gen_random_uuid(), 'support_email', '', 'Platform support email'),
    (gen_random_uuid(), 'farmer_approval_required', 'true', 'Whether farmer registration requires admin approval'),
    (gen_random_uuid(), 'default_currency', 'BWP', 'Default currency code for the platform'),
    (gen_random_uuid(), 'default_country', 'BW', 'Default country code (ISO 3166-1 alpha-2)');
