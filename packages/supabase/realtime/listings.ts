import { supabase } from '../client';
import type { RealtimeChannel } from '@supabase/supabase-js';

/** Store: subscribe to new active listings. Returns the channel for cleanup. */
export function subscribeToNewListings(
  callback: (payload: { new: Record<string, unknown> }) => void,
): RealtimeChannel {
  return supabase
    .channel('listings:active')
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'listings',
        filter: 'status=eq.active',
      },
      callback,
    )
    .subscribe();
}
