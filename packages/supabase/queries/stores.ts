import { supabase } from '../client';

const DEFAULT_PAGE_SIZE = 20;

/** Fetch single store with profile. */
export async function getStore(storeId: string) {
  const { data, error } = await supabase
    .from('stores')
    .select('*, profile:profiles(*)')
    .eq('id', storeId)
    .single();
  return { data, error };
}

/** Fetch store by profile ID. */
export async function getStoreByProfileId(profileId: string) {
  const { data, error } = await supabase
    .from('stores')
    .select('*, profile:profiles(*)')
    .eq('profile_id', profileId)
    .single();
  return { data, error };
}

/** Create store record. */
export async function createStore(data: {
  profile_id: string;
  business_name: string;
  store_type: string;
  location_lat?: number | null;
  location_lng?: number | null;
  address?: string | null;
  country_id?: string | null;
  contact_phone?: string | null;
  contact_email?: string | null;
  bio?: string | null;
  logo_url?: string | null;
}) {
  const { data: store, error } = await supabase
    .from('stores')
    .insert(data)
    .select('*, profile:profiles(*)')
    .single();
  return { data: store, error };
}

/** Update store record. */
export async function updateStore(storeId: string, updates: {
  business_name?: string;
  store_type?: string;
  location_lat?: number | null;
  location_lng?: number | null;
  address?: string | null;
  country_id?: string | null;
  contact_phone?: string | null;
  contact_email?: string | null;
  bio?: string | null;
  logo_url?: string | null;
}) {
  const { data, error } = await supabase
    .from('stores')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', storeId)
    .select('*, profile:profiles(*)')
    .single();
  return { data, error };
}

/** Admin: list all stores. */
export async function getAllStores(page = 1, pageSize = DEFAULT_PAGE_SIZE) {
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  const { data, error, count } = await supabase
    .from('stores')
    .select('*, profile:profiles(*)', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to);
  return { data, error, count };
}

/** Fetch store dashboard stat counts. */
export async function getStoreStats(storeId: string) {
  const [listings, orders, contracts, tenders] = await Promise.all([
    supabase
      .from('listings')
      .select('id', { count: 'exact', head: true })
      .eq('status', 'active'),
    supabase
      .from('orders')
      .select('id', { count: 'exact', head: true })
      .eq('store_id', storeId)
      .in('status', ['new', 'accepted', 'preparing', 'ready', 'in_transit']),
    supabase
      .from('contracts')
      .select('id', { count: 'exact', head: true })
      .eq('store_id', storeId)
      .in('status', ['accepted', 'active']),
    supabase
      .from('tenders')
      .select('id', { count: 'exact', head: true })
      .eq('store_id', storeId)
      .eq('status', 'active'),
  ]);

  return {
    data: {
      new_listings: listings.count ?? 0,
      open_orders: orders.count ?? 0,
      active_contracts: contracts.count ?? 0,
      active_tenders: tenders.count ?? 0,
    },
    error: null,
  };
}
