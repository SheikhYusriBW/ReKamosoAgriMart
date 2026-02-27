import { supabase } from '../client';

const DEFAULT_PAGE_SIZE = 20;

/** Create a new listing. */
export async function createListing(data: {
  farmer_id: string;
  product_id: string;
  variety_id?: string | null;
  title?: string | null;
  description?: string | null;
  quantity: number;
  quantity_remaining: number;
  unit_id: string;
  price_per_unit: number;
  currency_code?: string;
  quality_grade?: string | null;
  available_from: string;
  available_until: string;
  delivery_options?: string;
  status?: string;
}) {
  const { data: listing, error } = await supabase
    .from('listings')
    .insert(data)
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*), farmer:farmers(*, profile:profiles(*))')
    .single();
  return { data: listing, error };
}

/** Update a listing. */
export async function updateListing(listingId: string, updates: {
  title?: string | null;
  description?: string | null;
  quantity?: number;
  quantity_remaining?: number;
  unit_id?: string;
  price_per_unit?: number;
  quality_grade?: string | null;
  available_from?: string;
  available_until?: string;
  delivery_options?: string;
  status?: string;
}) {
  const { data, error } = await supabase
    .from('listings')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', listingId)
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*)')
    .single();
  return { data, error };
}

/** Delete a draft listing. */
export async function deleteListing(listingId: string) {
  const { error } = await supabase
    .from('listings')
    .delete()
    .eq('id', listingId)
    .eq('status', 'draft');
  return { error };
}

/** Get farmer's listings with optional status filter. */
export async function getMyListings(farmerId: string, filters?: {
  status?: string;
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
    .from('listings')
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*), images:listing_images(image_url)', { count: 'exact' })
    .eq('farmer_id', farmerId)
    .range(from, to);

  if (filters?.status) {
    query = query.eq('status', filters.status);
  }

  const sortBy = filters?.sortBy ?? 'created_at';
  const sortOrder = filters?.sortOrder ?? 'desc';
  query = query.order(sortBy, { ascending: sortOrder === 'asc' });

  const { data, error, count } = await query;
  return { data, error, count };
}

/** Browse active listings for stores. */
export async function getActiveListings(filters?: {
  productId?: string;
  categoryId?: string;
  search?: string;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  page?: number;
  pageSize?: number;
}) {
  const page = filters?.page ?? 1;
  const pageSize = filters?.pageSize ?? DEFAULT_PAGE_SIZE;
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  let query = supabase
    .from('listings')
    .select('*, product:products(*, category:product_categories(*)), variety:product_varieties(*), unit:units_of_measure(*), farmer:farmers(*, profile:profiles(*)), images:listing_images(image_url)', { count: 'exact' })
    .eq('status', 'active')
    .gt('quantity_remaining', 0)
    .range(from, to);

  if (filters?.productId) {
    query = query.eq('product_id', filters.productId);
  }

  if (filters?.search) {
    query = query.or(`title.ilike.%${filters.search}%,description.ilike.%${filters.search}%`);
  }

  const sortBy = filters?.sortBy ?? 'created_at';
  const sortOrder = filters?.sortOrder ?? 'desc';
  query = query.order(sortBy, { ascending: sortOrder === 'asc' });

  const { data, error, count } = await query;
  return { data, error, count };
}

/** Get single listing with all joins. */
export async function getListingById(listingId: string) {
  const { data, error } = await supabase
    .from('listings')
    .select('*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*), farmer:farmers(*, profile:profiles(*)), images:listing_images(*)')
    .eq('id', listingId)
    .single();
  return { data, error };
}

/** Atomically decrement listing quantity. MUST use RPC — never direct update. */
export async function decrementListingQuantity(listingId: string, quantity: number) {
  const { data, error } = await supabase.rpc('decrement_listing_quantity', {
    p_listing_id: listingId,
    p_ordered_qty: quantity,
  });
  return { data, error };
}

/** Upload listing image to storage. */
export async function uploadListingImage(listingId: string, file: Blob, sortOrder = 0) {
  const fileName = `${Date.now()}.jpg`;
  const filePath = `${listingId}/${fileName}`;

  const { error: uploadError } = await supabase.storage
    .from('listing-images')
    .upload(filePath, file);

  if (uploadError) return { data: null, error: uploadError };

  const { data: { publicUrl } } = supabase.storage
    .from('listing-images')
    .getPublicUrl(filePath);

  const { data, error } = await supabase
    .from('listing_images')
    .insert({ listing_id: listingId, image_url: publicUrl, sort_order: sortOrder })
    .select()
    .single();

  return { data, error };
}

/** Delete a listing image. */
export async function deleteListingImage(imageId: string) {
  const { error } = await supabase
    .from('listing_images')
    .delete()
    .eq('id', imageId);
  return { error };
}
