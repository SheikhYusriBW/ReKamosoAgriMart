# CURSOR PROMPT 2 — Database Schema, Migrations, Seed Data

> Paste everything below this line into Cursor.

---

## Context

Read `docs/DATABASE_SCHEMA.md` thoroughly — it contains all 26 tables, columns, types, constraints, relationships, indexes, RLS policies, triggers, and seed data. Every migration must match that document exactly.

Also reference `ARCHITECTURE.md` for the critical implementation patterns (atomic updates, RLS strategy, status flows).

## Task

Create all Supabase SQL migration files in `supabase/migrations/` plus the seed data file. These migrations will create the entire database schema for the ReKamoso AgriMart platform.

### Migration Files to Create

Create each file in order. Each migration should be a standalone SQL file that can run independently in sequence. Use the naming convention `YYYYMMDD000000_description.sql` (use `20250227` as the date prefix for all).

#### Table Migrations (in dependency order)

1. `20250227000001_create_profiles.sql`
   - Create `profiles` table linked to Supabase `auth.users`
   - Add a trigger that auto-creates a profile row when a new user signs up via Supabase Auth:
     ```sql
     CREATE OR REPLACE FUNCTION public.handle_new_user()
     RETURNS TRIGGER AS $$
     BEGIN
       INSERT INTO public.profiles (id, phone, full_name)
       VALUES (NEW.id, NEW.phone, COALESCE(NEW.raw_user_meta_data->>'full_name', ''));
       RETURN NEW;
     END;
     $$ LANGUAGE plpgsql SECURITY DEFINER;

     CREATE TRIGGER on_auth_user_created
       AFTER INSERT ON auth.users
       FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
     ```

2. `20250227000002_create_user_roles.sql`
   - Create `user_roles` table with unique constraint on (profile_id, role)

3. `20250227000003_create_currencies.sql`
   - Create `currencies` table

4. `20250227000004_create_countries.sql`
   - Create `countries` table with FK to currencies

5. `20250227000005_create_farmers.sql`
   - Create `farmers` table with all fields from DATABASE_SCHEMA.md including rating aggregates, verification fields, and `country_id` FK

6. `20250227000006_create_farm_images.sql`
   - Create `farm_images` table

7. `20250227000007_create_stores.sql`
   - Create `stores` table with `country_id` FK

8. `20250227000008_create_admin_users.sql`
   - Create `admin_users` table

9. `20250227000009_create_product_categories.sql`
   - Create `product_categories` table

10. `20250227000010_create_products.sql`
    - Create `products` table with unique constraint on (category_id, name)

11. `20250227000011_create_product_varieties.sql`
    - Create `product_varieties` table with unique constraint on (product_id, name)

12. `20250227000012_create_product_requests.sql`
    - Create `product_requests` table

13. `20250227000013_create_units_of_measure.sql`
    - Create `units_of_measure` table

14. `20250227000014_create_farmer_products.sql`
    - Create `farmer_products` table with unique constraint on (farmer_id, product_id)

15. `20250227000015_create_listings.sql`
    - Create `listings` table with all fields including `currency_code`
    - **IMPORTANT:** Add a comment noting that `quantity_remaining` MUST use atomic updates (see RPC functions migration)

16. `20250227000016_create_listing_images.sql`
    - Create `listing_images` table

17. `20250227000017_create_cropping_plans.sql`
    - Create `cropping_plans` table with FK to contracts (nullable)

18. `20250227000018_create_tenders.sql`
    - Create `tenders` table with all fields including `currency_code`
    - **IMPORTANT:** Add a comment noting that `quantity_fulfilled` MUST use atomic updates

19. `20250227000019_create_tender_offers.sql`
    - Create `tender_offers` table with unique constraint on (tender_id, farmer_id) and `currency_code`

20. `20250227000020_create_contracts.sql`
    - Create `contracts` table with all fields including `currency_code`

21. `20250227000021_create_contract_deliveries.sql`
    - Create `contract_deliveries` table

22. `20250227000022_create_orders.sql`
    - Create `orders` table with all fields including `currency_code`
    - Add a sequence and trigger for auto-generating order numbers (ORD-00001, ORD-00002, etc.):
      ```sql
      CREATE SEQUENCE order_number_seq START 1;

      CREATE OR REPLACE FUNCTION generate_order_number()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.order_number := 'ORD-' || LPAD(NEXTVAL('order_number_seq')::TEXT, 5, '0');
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER set_order_number
        BEFORE INSERT ON orders
        FOR EACH ROW EXECUTE FUNCTION generate_order_number();
      ```

23. `20250227000023_create_order_items.sql`
    - Create `order_items` table with `currency_code`

24. `20250227000024_create_reviews.sql`
    - Create `reviews` table with unique constraint on (order_id) and CHECK constraints on ratings (1-5)

25. `20250227000025_create_notifications.sql`
    - Create `notifications` table

26. `20250227000026_create_platform_settings.sql`
    - Create `platform_settings` table

#### Infrastructure Migrations

27. `20250227000027_create_indexes.sql`
    - Create ALL indexes listed in DATABASE_SCHEMA.md Indexes section
    - Include the user_roles indexes from the Additional Index section
    - Every index from the schema doc must be included

28. `20250227000028_create_rls_policies.sql`
    - Enable RLS on ALL 26 tables
    - Create policies for each table as specified in DATABASE_SCHEMA.md RLS section:

    **Profiles:**
    - Users can SELECT their own profile
    - Users can UPDATE their own profile
    - Admins can SELECT all profiles

    **User Roles:**
    - Users can SELECT their own roles
    - Only admins can INSERT/UPDATE/DELETE roles
    - Exception: the registration flow needs to insert a role for the current user (use a SECURITY DEFINER function for this)

    **Farmers:**
    - Farmers can SELECT and UPDATE their own record
    - Stores can SELECT approved farmer profiles (verification_status = 'approved')
    - Admins can SELECT and UPDATE all

    **Farm Images:**
    - Farmers can CRUD their own farm images
    - Public can SELECT (for display on farmer profiles)

    **Stores:**
    - Stores can SELECT and UPDATE their own record
    - Farmers can SELECT active stores
    - Admins can SELECT and UPDATE all

    **Admin Users:**
    - Only admins can access this table

    **Product Categories, Products, Product Varieties:**
    - All authenticated users can SELECT active items
    - Only admins can INSERT/UPDATE/DELETE

    **Product Requests:**
    - Farmers can INSERT and SELECT their own requests
    - Admins can SELECT all and UPDATE (approve/reject)

    **Units of Measure:**
    - All authenticated users can SELECT active units
    - Only admins can INSERT/UPDATE/DELETE

    **Farmer Products:**
    - Farmers can CRUD their own links
    - Stores can SELECT (to see what farmers grow)

    **Listings:**
    - Farmers can INSERT/UPDATE/DELETE their own listings
    - All authenticated users can SELECT active listings
    - Admins can SELECT all

    **Listing Images:**
    - Farmers can CRUD images on their own listings
    - Public can SELECT

    **Cropping Plans:**
    - Farmers can CRUD their own plans
    - Stores can SELECT all plans (forward visibility)
    - Admins can SELECT all

    **Tenders:**
    - Stores can CRUD their own tenders
    - Approved farmers can SELECT active tenders
    - Admins can SELECT all

    **Tender Offers:**
    - Farmers can INSERT and SELECT their own offers
    - Stores can SELECT offers on their own tenders and UPDATE (accept/decline)
    - Admins can SELECT all

    **Contracts:**
    - Stores can INSERT and SELECT/UPDATE their own contracts
    - Farmers can SELECT contracts where they are the farmer_id OR where is_public = true
    - Farmers can UPDATE contracts to accept (set farmer_id = their id, only when farmer_id IS NULL)
    - Admins can SELECT all

    **Contract Deliveries:**
    - Farmers can SELECT and UPDATE deliveries on their contracts
    - Stores can SELECT and UPDATE deliveries on their contracts
    - Admins can SELECT all

    **Orders:**
    - Stores can INSERT orders and SELECT/UPDATE their own orders
    - Farmers can SELECT and UPDATE their own orders (status changes)
    - Admins can SELECT all

    **Order Items:**
    - Same access as parent order (check via order_id join)
    - Simpler approach: stores and farmers can SELECT items on their own orders

    **Reviews:**
    - Stores can INSERT reviews on their own completed orders
    - All authenticated users can SELECT all reviews (public reputation)
    - Admins can SELECT all

    **Notifications:**
    - Users can SELECT and UPDATE (mark read) their own notifications
    - System/Edge Functions insert notifications (use service_role key)

    **Platform Settings:**
    - All authenticated users can SELECT
    - Only admins can UPDATE

    **Currencies, Countries:**
    - All authenticated users can SELECT active items
    - Only admins can INSERT/UPDATE/DELETE

    **Helper function for admin checks:**
    ```sql
    CREATE OR REPLACE FUNCTION public.is_admin()
    RETURNS BOOLEAN AS $$
    BEGIN
      RETURN EXISTS (
        SELECT 1 FROM public.user_roles
        WHERE profile_id = auth.uid()
        AND role = 'admin'
        AND is_active = true
      );
    END;
    $$ LANGUAGE plpgsql SECURITY DEFINER STABLE;
    ```

    **Helper function for role checks:**
    ```sql
    CREATE OR REPLACE FUNCTION public.has_role(required_role TEXT)
    RETURNS BOOLEAN AS $$
    BEGIN
      RETURN EXISTS (
        SELECT 1 FROM public.user_roles
        WHERE profile_id = auth.uid()
        AND role = required_role
        AND is_active = true
      );
    END;
    $$ LANGUAGE plpgsql SECURITY DEFINER STABLE;
    ```

29. `20250227000029_create_triggers.sql`
    - **updated_at auto-update trigger** — Create a reusable function and apply it to every table that has an `updated_at` column:
      ```sql
      CREATE OR REPLACE FUNCTION update_updated_at()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
      ```
      Apply to: profiles, farmers, stores, product_categories, products, listings, cropping_plans, tenders, tender_offers, contracts, contract_deliveries, orders, order_items

    - **Farmer rating recalculation trigger** — When a new review is inserted, recalculate the farmer's aggregate ratings:
      ```sql
      CREATE OR REPLACE FUNCTION recalculate_farmer_ratings()
      RETURNS TRIGGER AS $$
      BEGIN
        UPDATE farmers SET
          avg_overall_rating = (SELECT ROUND(AVG(overall_rating)::numeric, 2) FROM reviews WHERE farmer_id = NEW.farmer_id),
          avg_quality_rating = (SELECT ROUND(AVG(quality_rating)::numeric, 2) FROM reviews WHERE farmer_id = NEW.farmer_id),
          avg_reliability_rating = (SELECT ROUND(AVG(reliability_rating)::numeric, 2) FROM reviews WHERE farmer_id = NEW.farmer_id),
          total_reviews = (SELECT COUNT(*) FROM reviews WHERE farmer_id = NEW.farmer_id),
          total_transactions = (SELECT COUNT(*) FROM orders WHERE farmer_id = NEW.farmer_id AND status = 'confirmed'),
          updated_at = NOW()
        WHERE id = NEW.farmer_id;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql SECURITY DEFINER;

      CREATE TRIGGER on_review_created
        AFTER INSERT ON reviews
        FOR EACH ROW EXECUTE FUNCTION recalculate_farmer_ratings();
      ```

    - **Listing auto-sold trigger** — When quantity_remaining hits 0, auto-update status to 'sold':
      ```sql
      CREATE OR REPLACE FUNCTION check_listing_sold()
      RETURNS TRIGGER AS $$
      BEGIN
        IF NEW.quantity_remaining <= 0 AND NEW.status = 'active' THEN
          NEW.status := 'sold';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER on_listing_quantity_changed
        BEFORE UPDATE ON listings
        FOR EACH ROW
        WHEN (OLD.quantity_remaining IS DISTINCT FROM NEW.quantity_remaining)
        EXECUTE FUNCTION check_listing_sold();
      ```

    - **Tender auto-fulfilled trigger** — When quantity_fulfilled >= quantity_needed, auto-update status:
      ```sql
      CREATE OR REPLACE FUNCTION check_tender_fulfilled()
      RETURNS TRIGGER AS $$
      BEGIN
        IF NEW.quantity_fulfilled >= NEW.quantity_needed AND NEW.status = 'active' THEN
          NEW.status := 'fulfilled';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER on_tender_fulfillment_changed
        BEFORE UPDATE ON tenders
        FOR EACH ROW
        WHEN (OLD.quantity_fulfilled IS DISTINCT FROM NEW.quantity_fulfilled)
        EXECUTE FUNCTION check_tender_fulfilled();
      ```

30. `20250227000030_create_rpc_functions.sql`
    - **Atomic listing quantity decrement** (CRITICAL — prevents overselling):
      ```sql
      CREATE OR REPLACE FUNCTION decrement_listing_quantity(
        p_listing_id UUID,
        p_ordered_qty DECIMAL
      )
      RETURNS DECIMAL AS $$
      DECLARE
        v_remaining DECIMAL;
      BEGIN
        UPDATE listings
        SET quantity_remaining = quantity_remaining - p_ordered_qty,
            updated_at = NOW()
        WHERE id = p_listing_id
          AND quantity_remaining >= p_ordered_qty
          AND status = 'active'
        RETURNING quantity_remaining INTO v_remaining;

        RETURN v_remaining; -- NULL if update failed (insufficient quantity)
      END;
      $$ LANGUAGE plpgsql SECURITY DEFINER;
      ```

    - **Atomic tender fulfillment increment:**
      ```sql
      CREATE OR REPLACE FUNCTION increment_tender_fulfillment(
        p_tender_id UUID,
        p_fulfilled_qty DECIMAL
      )
      RETURNS DECIMAL AS $$
      DECLARE
        v_fulfilled DECIMAL;
      BEGIN
        UPDATE tenders
        SET quantity_fulfilled = quantity_fulfilled + p_fulfilled_qty,
            updated_at = NOW()
        WHERE id = p_tender_id
          AND status = 'active'
        RETURNING quantity_fulfilled INTO v_fulfilled;

        RETURN v_fulfilled;
      END;
      $$ LANGUAGE plpgsql SECURITY DEFINER;
      ```

    - **Atomic contract delivery update:**
      ```sql
      CREATE OR REPLACE FUNCTION update_contract_delivery_totals(
        p_contract_id UUID,
        p_delivered_qty DECIMAL
      )
      RETURNS DECIMAL AS $$
      DECLARE
        v_total DECIMAL;
        v_contracted DECIMAL;
      BEGIN
        UPDATE contracts
        SET total_delivered_qty = total_delivered_qty + p_delivered_qty,
            updated_at = NOW()
        WHERE id = p_contract_id
        RETURNING total_delivered_qty, total_contracted_qty INTO v_total, v_contracted;

        -- Recalculate fulfillment rate
        IF v_contracted > 0 THEN
          UPDATE contracts
          SET fulfillment_rate = ROUND((v_total / v_contracted * 100)::numeric, 2)
          WHERE id = p_contract_id;
        END IF;

        RETURN v_total;
      END;
      $$ LANGUAGE plpgsql SECURITY DEFINER;
      ```

    - **Assign farmer role during registration:**
      ```sql
      CREATE OR REPLACE FUNCTION assign_user_role(
        p_profile_id UUID,
        p_role TEXT
      )
      RETURNS VOID AS $$
      BEGIN
        INSERT INTO user_roles (profile_id, role)
        VALUES (p_profile_id, p_role)
        ON CONFLICT (profile_id, role) DO NOTHING;
      END;
      $$ LANGUAGE plpgsql SECURITY DEFINER;
      ```

#### Seed Data

31. `supabase/seed.sql`
    - Insert all seed data in dependency order:

    **Currencies:**
    - BWP (Botswana Pula, symbol: P, precision: 2, active: true)
    - ZAR (South African Rand, symbol: R, precision: 2, active: false)

    **Countries:**
    - BW (Botswana, linked to BWP, active: true)
    - ZA (South Africa, linked to ZAR, active: false)

    **Product Categories:**
    - Fruits (sort_order: 1)
    - Vegetables (sort_order: 2)
    - Herbs (sort_order: 3)
    - Leafy Greens (sort_order: 4)

    **Products (with correct category links):**
    - Fruits: Tomatoes, Apples, Oranges, Bananas, Grapes, Mangoes, Avocados, Peaches, Berries, Watermelon, Lemons
    - Vegetables: Cabbage, Onions, Potatoes, Butternut, Carrots, Green Beans, Peppers, Broccoli, Lettuce, Beetroot
    - Herbs: Parsley, Coriander, Basil, Mint, Rosemary
    - Leafy Greens: Spinach, Kale, Swiss Chard, Rocket, Baby Spinach

    **Product Varieties (common ones):**
    - Tomatoes: Roma, Cherry, Beef, Grape
    - Peppers: Green, Red, Yellow, Chilli
    - Onions: Red, White, Spring
    - Potatoes: Russet, Sweet, Baby
    - Apples: Granny Smith, Fuji, Golden Delicious
    - Oranges: Navel, Valencia
    - Bananas: Cavendish, Lady Finger
    - Basil: Sweet, Thai, Purple

    **Units of Measure:**
    - Kilogram (kg, context: both, sort: 1)
    - Tonne (t, context: farmer_to_store, sort: 2)
    - Crate (crate, context: farmer_to_store, sort: 3)
    - Bunch (bunch, context: both, sort: 4)
    - Bag (bag, context: farmer_to_store, sort: 5)
    - Each (each, context: both, sort: 6)
    - Gram (g, context: store_to_consumer, sort: 7)
    - Pack (pack, context: store_to_consumer, sort: 8)

    **Platform Settings:**
    - commission_rate: '0' (TBD)
    - platform_name: 'ReKamoso AgriMart'
    - support_phone: '' (TBD)
    - support_email: '' (TBD)
    - farmer_approval_required: 'true'
    - default_currency: 'BWP'
    - default_country: 'BW'

    Use UUIDs generated with `gen_random_uuid()` or hardcoded UUIDs for seed data so foreign key references work. Use variables or CTEs to reference category IDs when inserting products.

### Storage Buckets

32. `20250227000031_create_storage_buckets.sql`
    - Create Supabase Storage buckets:
      ```sql
      INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);
      INSERT INTO storage.buckets (id, name, public) VALUES ('farm-images', 'farm-images', true);
      INSERT INTO storage.buckets (id, name, public) VALUES ('listing-images', 'listing-images', true);
      INSERT INTO storage.buckets (id, name, public) VALUES ('store-logos', 'store-logos', true);
      INSERT INTO storage.buckets (id, name, public) VALUES ('product-images', 'product-images', true);
      ```
    - Add storage policies:
      - Authenticated users can upload to any bucket
      - Public can read from all buckets (they're public buckets)
      - Users can only delete their own uploads

## Requirements

- Every column, type, constraint, and default value MUST match `docs/DATABASE_SCHEMA.md` exactly
- Use `UUID` with `DEFAULT gen_random_uuid()` for all primary keys
- Use `TIMESTAMPTZ` with `DEFAULT NOW()` for all timestamp columns
- All foreign key references must include `ON DELETE` behavior:
  - Most FKs: `ON DELETE CASCADE` (if parent is deleted, children are deleted)
  - Exception: `orders.listing_id`, `orders.tender_offer_id`, `orders.contract_delivery_id` should be `ON DELETE SET NULL` (preserve order history even if source is deleted)
  - Exception: `farmers.verified_by` should be `ON DELETE SET NULL`
- Include SQL comments explaining the purpose of each table and any critical implementation notes
- RLS policies should use the `is_admin()` and `has_role()` helper functions where appropriate
- Seed data should use CTEs or variables to handle foreign key references between tables cleanly

## Do NOT

- Do not modify any existing files from Prompt 1
- Do not create any app code — only SQL migration files and seed.sql
- Do not skip any table, index, policy, or trigger from the schema document

## Expected Result

After this task, I should be able to:
1. Link my local Supabase CLI to my remote project: `supabase link --project-ref <project-id>`
2. Push all migrations: `supabase db push`
3. Run seed data: either via Supabase dashboard SQL editor or `supabase db reset` (which runs migrations + seed)
4. Open Supabase Studio and see all 26 tables with correct columns, relationships, RLS policies, and seed data populated
