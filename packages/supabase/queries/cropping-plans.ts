import { supabase } from '../client';

const DEFAULT_PAGE_SIZE = 20;

/** Create a cropping plan. */
export async function createCroppingPlan(data: {
  farmer_id: string;
  product_id: string;
  variety_id?: string | null;
  date_planted: string;
  expected_harvest_date: string;
  estimated_yield?: number | null;
  yield_unit_id?: string | null;
  growing_status?: string;
  notes?: string | null;
}) {
  const { data: plan, error } = await supabase
    .from('cropping_plans')
    .insert(data)
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*)')
    .single();
  return { data: plan, error };
}

/** Update a cropping plan. */
export async function updateCroppingPlan(planId: string, updates: {
  expected_harvest_date?: string;
  estimated_yield?: number | null;
  actual_yield?: number | null;
  growing_status?: string;
  is_contracted?: boolean;
  contract_id?: string | null;
  notes?: string | null;
}) {
  const { data, error } = await supabase
    .from('cropping_plans')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', planId)
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*)')
    .single();
  return { data, error };
}

/** Get farmer's cropping plans with optional status filter. */
export async function getMyCroppingPlans(farmerId: string, filters?: {
  status?: string;
  page?: number;
  pageSize?: number;
}) {
  const page = filters?.page ?? 1;
  const pageSize = filters?.pageSize ?? DEFAULT_PAGE_SIZE;
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  let query = supabase
    .from('cropping_plans')
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*), contract:contracts(*)', { count: 'exact' })
    .eq('farmer_id', farmerId)
    .order('expected_harvest_date', { ascending: true })
    .range(from, to);

  if (filters?.status) {
    query = query.eq('growing_status', filters.status);
  }

  const { data, error, count } = await query;
  return { data, error, count };
}

/** Store: browse all cropping plans (for forward visibility). */
export async function getAllCroppingPlans(filters?: {
  productId?: string;
  page?: number;
  pageSize?: number;
}) {
  const page = filters?.page ?? 1;
  const pageSize = filters?.pageSize ?? DEFAULT_PAGE_SIZE;
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  let query = supabase
    .from('cropping_plans')
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*), farmer:farmers(*, profile:profiles(*))', { count: 'exact' })
    .neq('growing_status', 'harvested')
    .eq('is_contracted', false)
    .order('expected_harvest_date', { ascending: true })
    .range(from, to);

  if (filters?.productId) {
    query = query.eq('product_id', filters.productId);
  }

  const { data, error, count } = await query;
  return { data, error, count };
}

/** Get single cropping plan with all joins. */
export async function getCroppingPlanById(planId: string) {
  const { data, error } = await supabase
    .from('cropping_plans')
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*), contract:contracts(*)')
    .eq('id', planId)
    .single();
  return { data, error };
}
