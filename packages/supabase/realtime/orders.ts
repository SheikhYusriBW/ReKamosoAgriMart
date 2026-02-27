import { supabase } from '../client';
import type { RealtimeChannel } from '@supabase/supabase-js';

/** Farmer: subscribe to new orders. Returns the channel for cleanup. */
export function subscribeToOrdersAsFarmer(
  farmerId: string,
  callback: (payload: { new: Record<string, unknown> }) => void,
): RealtimeChannel {
  return supabase
    .channel(`orders:farmer:${farmerId}`)
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'orders',
        filter: `farmer_id=eq.${farmerId}`,
      },
      callback,
    )
    .subscribe();
}

/** Subscribe to status changes on a specific order. Returns the channel for cleanup. */
export function subscribeToOrderStatusChanges(
  orderId: string,
  callback: (payload: { new: Record<string, unknown>; old: Record<string, unknown> }) => void,
): RealtimeChannel {
  return supabase
    .channel(`order:${orderId}`)
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'orders',
        filter: `id=eq.${orderId}`,
      },
      callback,
    )
    .subscribe();
}
