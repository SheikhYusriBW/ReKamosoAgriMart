import { supabase } from '../client';

const DEFAULT_PAGE_SIZE = 20;

/** Store creates a tender. */
export async function createTender(data: {
  store_id: string;
  product_id: string;
  variety_id?: string | null;
  quantity_needed: number;
  unit_id: string;
  min_price?: number | null;
  max_price?: number | null;
  currency_code?: string;
  date_needed_by: string;
  quality_requirements?: string | null;
  delivery_preference?: string;
  expires_at?: string | null;
}) {
  const { data: tender, error } = await supabase
    .from('tenders')
    .insert(data)
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*), store:stores(*, profile:profiles(*))')
    .single();
  return { data: tender, error };
}

/** Update a tender. */
export async function updateTender(tenderId: string, updates: {
  quantity_needed?: number;
  min_price?: number | null;
  max_price?: number | null;
  date_needed_by?: string;
  quality_requirements?: string | null;
  delivery_preference?: string;
  status?: string;
  expires_at?: string | null;
}) {
  const { data, error } = await supabase
    .from('tenders')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', tenderId)
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*)')
    .single();
  return { data, error };
}

/** Get store's tenders with optional status filter. */
export async function getMyTenders(storeId: string, filters?: {
  status?: string;
  page?: number;
  pageSize?: number;
}) {
  const page = filters?.page ?? 1;
  const pageSize = filters?.pageSize ?? DEFAULT_PAGE_SIZE;
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  let query = supabase
    .from('tenders')
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*)', { count: 'exact' })
    .eq('store_id', storeId)
    .order('created_at', { ascending: false })
    .range(from, to);

  if (filters?.status) {
    query = query.eq('status', filters.status);
  }

  const { data, error, count } = await query;
  return { data, error, count };
}

/** Farmer: browse active tenders. */
export async function getActiveTenders(filters?: {
  productId?: string;
  page?: number;
  pageSize?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}) {
  const page = filters?.page ?? 1;
  const pageSize = filters?.pageSize ?? DEFAULT_PAGE_SIZE;
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  let query = supabase
    .from('tenders')
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*), store:stores(*, profile:profiles(*))', { count: 'exact' })
    .eq('status', 'active')
    .gte('date_needed_by', new Date().toISOString().split('T')[0])
    .range(from, to);

  if (filters?.productId) {
    query = query.eq('product_id', filters.productId);
  }

  const sortBy = filters?.sortBy ?? 'date_needed_by';
  const sortOrder = filters?.sortOrder ?? 'asc';
  query = query.order(sortBy, { ascending: sortOrder === 'asc' });

  const { data, error, count } = await query;
  return { data, error, count };
}

/** Get single tender with all joins. */
export async function getTenderById(tenderId: string) {
  const { data, error } = await supabase
    .from('tenders')
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*), store:stores(*, profile:profiles(*))')
    .eq('id', tenderId)
    .single();
  return { data, error };
}

/** Atomically increment tender fulfillment. MUST use RPC — never direct update. */
export async function incrementTenderFulfillment(tenderId: string, quantity: number) {
  const { data, error } = await supabase.rpc('increment_tender_fulfillment', {
    p_tender_id: tenderId,
    p_qty: quantity,
  });
  return { data, error };
}
