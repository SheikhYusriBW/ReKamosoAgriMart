import { supabase } from '../client';

/** Get units of measure, optionally filtered by context. */
export async function getUnits(context?: 'farmer_to_store' | 'store_to_consumer' | 'both') {
  let query = supabase
    .from('units_of_measure')
    .select('*')
    .eq('is_active', true)
    .order('sort_order', { ascending: true });

  if (context) {
    query = query.or(`context.eq.${context},context.eq.both`);
  }

  const { data, error } = await query;
  return { data, error };
}
