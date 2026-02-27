import { supabase } from '../client';

/** List currencies, optionally only active ones. */
export async function getCurrencies(activeOnly = true) {
  let query = supabase
    .from('currencies')
    .select('*')
    .order('code', { ascending: true });

  if (activeOnly) {
    query = query.eq('is_active', true);
  }

  const { data, error } = await query;
  return { data, error };
}

/** List countries with currency, optionally only active ones. */
export async function getCountries(activeOnly = true) {
  let query = supabase
    .from('countries')
    .select('*, currency:currencies(*)')
    .order('name', { ascending: true });

  if (activeOnly) {
    query = query.eq('is_active', true);
  }

  const { data, error } = await query;
  return { data, error };
}

/** Get single currency by code. */
export async function getCurrencyByCode(code: string) {
  const { data, error } = await supabase
    .from('currencies')
    .select('*')
    .eq('code', code)
    .single();
  return { data, error };
}
