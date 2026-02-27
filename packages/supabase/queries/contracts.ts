import { supabase } from '../client';

const DEFAULT_PAGE_SIZE = 20;

/** Store creates a contract. */
export async function createContract(data: {
  store_id: string;
  farmer_id?: string | null;
  product_id: string;
  variety_id?: string | null;
  quantity_per_delivery: number;
  unit_id: string;
  price_per_unit: number;
  currency_code?: string;
  delivery_frequency: string;
  custom_frequency_days?: number | null;
  quality_standards?: string | null;
  payment_terms?: string | null;
  start_date: string;
  end_date: string;
  total_contracted_qty?: number | null;
  is_public?: boolean;
}) {
  const { data: contract, error } = await supabase
    .from('contracts')
    .insert(data)
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*), store:stores(*, profile:profiles(*))')
    .single();
  return { data: contract, error };
}

/** Update a contract. */
export async function updateContract(contractId: string, updates: {
  quantity_per_delivery?: number;
  price_per_unit?: number;
  quality_standards?: string | null;
  payment_terms?: string | null;
  status?: string;
}) {
  const { data, error } = await supabase
    .from('contracts')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', contractId)
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*)')
    .single();
  return { data, error };
}

/** Get user's contracts by role. */
export async function getMyContracts(userId: string, role: 'farmer' | 'store', filters?: {
  status?: string;
  page?: number;
  pageSize?: number;
}) {
  const page = filters?.page ?? 1;
  const pageSize = filters?.pageSize ?? DEFAULT_PAGE_SIZE;
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  const roleColumn = role === 'farmer' ? 'farmer_id' : 'store_id';

  let query = supabase
    .from('contracts')
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*), farmer:farmers(*, profile:profiles(*)), store:stores(*, profile:profiles(*)), deliveries:contract_deliveries(*)', { count: 'exact' })
    .eq(roleColumn, userId)
    .order('created_at', { ascending: false })
    .range(from, to);

  if (filters?.status) {
    query = query.eq('status', filters.status);
  }

  const { data, error, count } = await query;
  return { data, error, count };
}

/** Get single contract with all joins and deliveries. */
export async function getContractById(contractId: string) {
  const { data, error } = await supabase
    .from('contracts')
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*), farmer:farmers(*, profile:profiles(*)), store:stores(*, profile:profiles(*)), deliveries:contract_deliveries(*)')
    .eq('id', contractId)
    .single();
  return { data, error };
}

/** Farmer accepts a contract. */
export async function acceptContract(contractId: string, farmerId: string) {
  const { data, error } = await supabase
    .from('contracts')
    .update({
      farmer_id: farmerId,
      status: 'accepted',
      updated_at: new Date().toISOString(),
    })
    .eq('id', contractId)
    .eq('status', 'open')
    .select('*, product:products(*), store:stores(*, profile:profiles(*))')
    .single();
  return { data, error };
}

/** Cancel a contract. */
export async function cancelContract(contractId: string) {
  const { data, error } = await supabase
    .from('contracts')
    .update({
      status: 'cancelled',
      updated_at: new Date().toISOString(),
    })
    .eq('id', contractId)
    .select()
    .single();
  return { data, error };
}

/** Farmer: browse public open contracts. */
export async function getOpenContracts(filters?: {
  productId?: string;
  page?: number;
  pageSize?: number;
}) {
  const page = filters?.page ?? 1;
  const pageSize = filters?.pageSize ?? DEFAULT_PAGE_SIZE;
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  let query = supabase
    .from('contracts')
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*), store:stores(*, profile:profiles(*))', { count: 'exact' })
    .eq('status', 'open')
    .eq('is_public', true)
    .order('created_at', { ascending: false })
    .range(from, to);

  if (filters?.productId) {
    query = query.eq('product_id', filters.productId);
  }

  const { data, error, count } = await query;
  return { data, error, count };
}
