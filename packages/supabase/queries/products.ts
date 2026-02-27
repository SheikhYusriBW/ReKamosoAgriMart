import { supabase } from '../client';

/** Get all active categories. */
export async function getCategories() {
  const { data, error } = await supabase
    .from('product_categories')
    .select('*')
    .eq('is_active', true)
    .order('sort_order', { ascending: true });
  return { data, error };
}

/** Get products, optionally filtered by category. */
export async function getProducts(categoryId?: string) {
  let query = supabase
    .from('products')
    .select('*, category:product_categories(*)')
    .eq('is_active', true)
    .order('sort_order', { ascending: true });

  if (categoryId) {
    query = query.eq('category_id', categoryId);
  }

  const { data, error } = await query;
  return { data, error };
}

/** Get varieties for a product. */
export async function getProductVarieties(productId: string) {
  const { data, error } = await supabase
    .from('product_varieties')
    .select('*')
    .eq('product_id', productId)
    .eq('is_active', true)
    .order('name', { ascending: true });
  return { data, error };
}

/** Get single product with category and varieties. */
export async function getProductById(productId: string) {
  const { data, error } = await supabase
    .from('products')
    .select('*, category:product_categories(*), varieties:product_varieties(*)')
    .eq('id', productId)
    .single();
  return { data, error };
}

/** Admin: add product. */
export async function createProduct(data: {
  category_id: string;
  name: string;
  description?: string | null;
  image_url?: string | null;
  sort_order?: number;
}) {
  const { data: product, error } = await supabase
    .from('products')
    .insert(data)
    .select('*, category:product_categories(*)')
    .single();
  return { data: product, error };
}

/** Admin: update product. */
export async function updateProduct(productId: string, updates: {
  name?: string;
  category_id?: string;
  description?: string | null;
  image_url?: string | null;
  sort_order?: number;
  is_active?: boolean;
}) {
  const { data, error } = await supabase
    .from('products')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', productId)
    .select('*, category:product_categories(*)')
    .single();
  return { data, error };
}

/** Farmer: request new product. */
export async function createProductRequest(data: {
  farmer_id: string;
  product_name: string;
  suggested_category_id?: string | null;
  description?: string | null;
}) {
  const { data: request, error } = await supabase
    .from('product_requests')
    .insert(data)
    .select()
    .single();
  return { data: request, error };
}

/** Admin: list pending product requests. */
export async function getPendingProductRequests() {
  const { data, error } = await supabase
    .from('product_requests')
    .select('*, farmer:farmers(*, profile:profiles(*)), suggested_category:product_categories(*)')
    .eq('status', 'pending')
    .order('created_at', { ascending: true });
  return { data, error };
}

/** Admin: approve product request and create product. */
export async function approveProductRequest(
  requestId: string,
  productData: { category_id: string; name: string; description?: string | null },
  adminId: string,
) {
  const { data: product, error: productError } = await supabase
    .from('products')
    .insert(productData)
    .select()
    .single();

  if (productError) return { data: null, error: productError };

  const { data, error } = await supabase
    .from('product_requests')
    .update({
      status: 'approved',
      reviewed_by: adminId,
      reviewed_at: new Date().toISOString(),
      created_product_id: product.id,
    })
    .eq('id', requestId)
    .select()
    .single();

  return { data, error };
}

/** Admin: reject product request. */
export async function rejectProductRequest(requestId: string, reason: string, adminId: string) {
  const { data, error } = await supabase
    .from('product_requests')
    .update({
      status: 'rejected',
      admin_notes: reason,
      reviewed_by: adminId,
      reviewed_at: new Date().toISOString(),
    })
    .eq('id', requestId)
    .select()
    .single();
  return { data, error };
}
