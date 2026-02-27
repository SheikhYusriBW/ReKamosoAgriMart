import { supabase } from '../client';

const DEFAULT_PAGE_SIZE = 20;

/** Fetch single farmer with profile. */
export async function getFarmer(farmerId: string) {
  const { data, error } = await supabase
    .from('farmers')
    .select('*, profile:profiles(*)')
    .eq('id', farmerId)
    .single();
  return { data, error };
}

/** Fetch farmer by their profile ID. */
export async function getFarmerByProfileId(profileId: string) {
  const { data, error } = await supabase
    .from('farmers')
    .select('*, profile:profiles(*)')
    .eq('profile_id', profileId)
    .single();
  return { data, error };
}

/** Create farmer record. */
export async function createFarmer(data: {
  profile_id: string;
  farm_name: string;
  farm_location_lat?: number | null;
  farm_location_lng?: number | null;
  farm_address?: string | null;
  country_id?: string | null;
  farm_size?: string | null;
  farm_size_unit?: string | null;
  id_number?: string | null;
  bio?: string | null;
}) {
  const { data: farmer, error } = await supabase
    .from('farmers')
    .insert(data)
    .select('*, profile:profiles(*)')
    .single();
  return { data: farmer, error };
}

/** Update farmer record. */
export async function updateFarmer(farmerId: string, updates: {
  farm_name?: string;
  farm_location_lat?: number | null;
  farm_location_lng?: number | null;
  farm_address?: string | null;
  country_id?: string | null;
  farm_size?: string | null;
  farm_size_unit?: string | null;
  id_number?: string | null;
  bio?: string | null;
}) {
  const { data, error } = await supabase
    .from('farmers')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', farmerId)
    .select('*, profile:profiles(*)')
    .single();
  return { data, error };
}

/** List approved farmers with optional filters. */
export async function getApprovedFarmers(filters?: {
  search?: string;
  page?: number;
  pageSize?: number;
}) {
  const page = filters?.page ?? 1;
  const pageSize = filters?.pageSize ?? DEFAULT_PAGE_SIZE;
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  let query = supabase
    .from('farmers')
    .select('*, profile:profiles(*)', { count: 'exact' })
    .eq('verification_status', 'approved')
    .order('created_at', { ascending: false })
    .range(from, to);

  if (filters?.search) {
    query = query.ilike('farm_name', `%${filters.search}%`);
  }

  const { data, error, count } = await query;
  return { data, error, count };
}

/** Admin: list pending farmer applications. */
export async function getPendingFarmers(page = 1, pageSize = DEFAULT_PAGE_SIZE) {
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  const { data, error, count } = await supabase
    .from('farmers')
    .select('*, profile:profiles(*)', { count: 'exact' })
    .eq('verification_status', 'pending')
    .order('created_at', { ascending: true })
    .range(from, to);
  return { data, error, count };
}

/** Admin: approve farmer. */
export async function approveFarmer(farmerId: string, adminId: string) {
  const { data, error } = await supabase
    .from('farmers')
    .update({
      verification_status: 'approved',
      verified_at: new Date().toISOString(),
      verified_by: adminId,
      updated_at: new Date().toISOString(),
    })
    .eq('id', farmerId)
    .select()
    .single();
  return { data, error };
}

/** Admin: reject farmer. */
export async function rejectFarmer(farmerId: string, reason: string) {
  const { data, error } = await supabase
    .from('farmers')
    .update({
      verification_status: 'rejected',
      rejection_reason: reason,
      updated_at: new Date().toISOString(),
    })
    .eq('id', farmerId)
    .select()
    .single();
  return { data, error };
}

/** Admin: suspend farmer. */
export async function suspendFarmer(farmerId: string) {
  const { data, error } = await supabase
    .from('farmers')
    .update({
      verification_status: 'suspended',
      updated_at: new Date().toISOString(),
    })
    .eq('id', farmerId)
    .select()
    .single();
  return { data, error };
}

/** Get products a farmer grows. */
export async function getFarmerProducts(farmerId: string) {
  const { data, error } = await supabase
    .from('farmer_products')
    .select('*, product:products(*, category:product_categories(*))')
    .eq('farmer_id', farmerId);
  return { data, error };
}

/** Replace farmer's product list. */
export async function setFarmerProducts(farmerId: string, productIds: string[]) {
  const { error: deleteError } = await supabase
    .from('farmer_products')
    .delete()
    .eq('farmer_id', farmerId);

  if (deleteError) return { data: null, error: deleteError };

  if (productIds.length === 0) return { data: [], error: null };

  const rows = productIds.map((productId) => ({
    farmer_id: farmerId,
    product_id: productId,
  }));

  const { data, error } = await supabase
    .from('farmer_products')
    .insert(rows)
    .select('*, product:products(*)');
  return { data, error };
}

/** Fetch farmer dashboard stat counts. */
export async function getFarmerStats(farmerId: string) {
  const [listings, orders, contracts, farmer] = await Promise.all([
    supabase
      .from('listings')
      .select('id', { count: 'exact', head: true })
      .eq('farmer_id', farmerId)
      .eq('status', 'active'),
    supabase
      .from('orders')
      .select('id', { count: 'exact', head: true })
      .eq('farmer_id', farmerId)
      .in('status', ['new', 'accepted', 'preparing', 'ready', 'in_transit']),
    supabase
      .from('contracts')
      .select('id', { count: 'exact', head: true })
      .eq('farmer_id', farmerId)
      .in('status', ['accepted', 'active']),
    supabase
      .from('farmers')
      .select('avg_overall_rating')
      .eq('id', farmerId)
      .single(),
  ]);

  return {
    data: {
      active_listings: listings.count ?? 0,
      open_orders: orders.count ?? 0,
      active_contracts: contracts.count ?? 0,
      avg_rating: farmer.data?.avg_overall_rating ?? 0,
    },
    error: null,
  };
}
