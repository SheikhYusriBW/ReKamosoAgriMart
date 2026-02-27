-- Migration: Create admin_users table
-- Description: Lightweight table to flag which profiles have admin access. Used alongside the admin panel.

CREATE TABLE public.admin_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    permissions VARCHAR(20) NOT NULL DEFAULT 'full',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Valid permission levels
    CONSTRAINT chk_admin_users_permissions CHECK (
        permissions IN ('full', 'read_only')
    )
);

-- Add table comment
COMMENT ON TABLE public.admin_users IS 'Admin access flags. Links to profiles with admin role.';

-- Add column comments
COMMENT ON COLUMN public.admin_users.profile_id IS 'Link to base profile - unique 1:1 relationship';
COMMENT ON COLUMN public.admin_users.permissions IS 'Permission level: full or read_only (future use)';
