-- Migration: Create platform_settings table
-- Description: Global platform configuration. Key-value store for settings.

CREATE TABLE public.platform_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key VARCHAR(100) NOT NULL UNIQUE,
    value TEXT NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

-- Add table comment
COMMENT ON TABLE public.platform_settings IS 'Global platform configuration. Key-value store for admin-editable settings.';

-- Add column comments
COMMENT ON COLUMN public.platform_settings.key IS 'Setting key (unique)';
COMMENT ON COLUMN public.platform_settings.value IS 'Setting value';
COMMENT ON COLUMN public.platform_settings.description IS 'What this setting controls';
COMMENT ON COLUMN public.platform_settings.updated_by IS 'Admin who last updated';
