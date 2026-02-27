import { supabase } from '../client';

const DEFAULT_PAGE_SIZE = 20;

/** Store creates a review for an order. */
export async function createReview(data: {
  order_id: string;
  store_id: string;
  farmer_id: string;
  overall_rating: number;
  quality_rating: number;
  reliability_rating: number;
  comment?: string | null;
}) {
  const { data: review, error } = await supabase
    .from('reviews')
    .insert(data)
    .select()
    .single();
  return { data: review, error };
}

/** Get all reviews for a farmer. */
export async function getReviewsForFarmer(farmerId: string, page = 1, pageSize = DEFAULT_PAGE_SIZE) {
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  const { data, error, count } = await supabase
    .from('reviews')
    .select('*, store:stores(*, profile:profiles(*)), order:orders(*)', { count: 'exact' })
    .eq('farmer_id', farmerId)
    .order('created_at', { ascending: false })
    .range(from, to);
  return { data, error, count };
}

/** Get single review for an order. */
export async function getReviewForOrder(orderId: string) {
  const { data, error } = await supabase
    .from('reviews')
    .select('*, store:stores(*, profile:profiles(*))')
    .eq('order_id', orderId)
    .single();
  return { data, error };
}
