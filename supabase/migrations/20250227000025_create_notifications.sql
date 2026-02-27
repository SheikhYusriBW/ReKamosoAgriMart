-- Migration: Create notifications table
-- Description: Record of all notifications sent. Used for in-app notification feed and tracking delivery status.

CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    channel VARCHAR(20) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    push_sent BOOLEAN NOT NULL DEFAULT FALSE,
    whatsapp_sent BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Valid channels
    CONSTRAINT chk_notifications_channel CHECK (
        channel IN ('push', 'whatsapp', 'both')
    )
);

-- Add table comment
COMMENT ON TABLE public.notifications IS 'All notification records for in-app feed and delivery tracking. Inserted by Edge Functions.';

-- Add column comments
COMMENT ON COLUMN public.notifications.recipient_id IS 'User receiving the notification';
COMMENT ON COLUMN public.notifications.type IS 'Notification type (e.g., farmer_approved, new_tender_match, order_placed_on_listing)';
COMMENT ON COLUMN public.notifications.title IS 'Notification title';
COMMENT ON COLUMN public.notifications.body IS 'Notification body text';
COMMENT ON COLUMN public.notifications.data IS 'Additional data payload (e.g., order_id, listing_id)';
COMMENT ON COLUMN public.notifications.channel IS 'Delivery channel: push, whatsapp, or both';
COMMENT ON COLUMN public.notifications.is_read IS 'Has the user seen this in-app';
COMMENT ON COLUMN public.notifications.push_sent IS 'Was push notification sent successfully';
COMMENT ON COLUMN public.notifications.whatsapp_sent IS 'Was WhatsApp message sent successfully';
