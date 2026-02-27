-- Migration: Create profiles table
-- Description: Base user profile linked to Supabase Auth. Every user (farmer, store operator, admin) has a profile.
-- The id matches Supabase auth.users.id (1:1 relationship)

-- Create profiles table
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(255) UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Foreign key to Supabase auth.users
    CONSTRAINT fk_profiles_auth_users FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Add table comment
COMMENT ON TABLE public.profiles IS 'Base user profile linked 1:1 with Supabase auth.users. All users (farmers, stores, admins) have a profile row.';

-- Add column comments
COMMENT ON COLUMN public.profiles.id IS 'Matches auth.users.id - same UUID';
COMMENT ON COLUMN public.profiles.phone IS 'Phone number used for OTP login';
COMMENT ON COLUMN public.profiles.email IS 'Optional email address';
COMMENT ON COLUMN public.profiles.full_name IS 'User full name';
COMMENT ON COLUMN public.profiles.avatar_url IS 'Profile photo URL from Supabase Storage';

-- Function to auto-create profile when a new user signs up via Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, phone, full_name)
    VALUES (NEW.id, NEW.phone, COALESCE(NEW.raw_user_meta_data->>'full_name', ''));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to execute the function after user signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
