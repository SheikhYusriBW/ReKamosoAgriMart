import { supabase } from '../client';
import type { RealtimeChannel } from '@supabase/supabase-js';

/** Farmer: subscribe to new active tenders. Returns the channel for cleanup. */
export function subscribeToNewTenders(
  callback: (payload: { new: Record<string, unknown> }) => void,
): RealtimeChannel {
  return supabase
    .channel('tenders:active')
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'tenders',
        filter: 'status=eq.active',
      },
      callback,
    )
    .subscribe();
}

/** Store: subscribe to new offers on their tender. Returns the channel for cleanup. */
export function subscribeToTenderOffers(
  tenderId: string,
  callback: (payload: { new: Record<string, unknown> }) => void,
): RealtimeChannel {
  return supabase
    .channel(`tender_offers:${tenderId}`)
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'tender_offers',
        filter: `tender_id=eq.${tenderId}`,
      },
      callback,
    )
    .subscribe();
}
