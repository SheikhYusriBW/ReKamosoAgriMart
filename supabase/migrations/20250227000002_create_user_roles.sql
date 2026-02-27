-- Migration: Create user_roles table
-- Description: Join table linking profiles to their roles. A user can have one or more roles (farmer, store, admin).

CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- A user can only have each role once
    CONSTRAINT uq_user_roles_profile_role UNIQUE (profile_id, role),

    -- Valid roles only
    CONSTRAINT chk_user_roles_valid_role CHECK (role IN ('farmer', 'store', 'admin'))
);

-- Add table comment
COMMENT ON TABLE public.user_roles IS 'Join table for multi-role support. A user can be both a farmer and store operator.';

-- Add column comments
COMMENT ON COLUMN public.user_roles.profile_id IS 'The user this role belongs to';
COMMENT ON COLUMN public.user_roles.role IS 'Role type: farmer, store, or admin';
COMMENT ON COLUMN public.user_roles.is_active IS 'Can deactivate a role without deleting (e.g., suspend farming ability while keeping store role)';
