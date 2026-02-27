import { supabase } from '../client';
import type { RealtimeChannel } from '@supabase/supabase-js';

/** Subscribe to new notifications for a user. Returns the channel for cleanup. */
export function subscribeToNotifications(
  userId: string,
  callback: (payload: { new: Record<string, unknown> }) => void,
): RealtimeChannel {
  return supabase
    .channel(`notifications:${userId}`)
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'notifications',
        filter: `recipient_id=eq.${userId}`,
      },
      callback,
    )
    .subscribe();
}
