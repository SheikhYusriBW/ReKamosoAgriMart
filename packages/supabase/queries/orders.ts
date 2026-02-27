import { supabase } from '../client';

const DEFAULT_PAGE_SIZE = 20;

/** Create an order with items. */
export async function createOrder(
  orderData: {
    order_number: string;
    store_id: string;
    farmer_id: string;
    source: string;
    listing_id?: string | null;
    tender_offer_id?: string | null;
    contract_delivery_id?: string | null;
    delivery_method: string;
    delivery_date?: string | null;
    delivery_address?: string | null;
    pickup_address?: string | null;
    subtotal: number;
    currency_code?: string;
    commission_rate?: number;
    commission_amount?: number;
  },
  items: Array<{
    product_id: string;
    variety_id?: string | null;
    quantity: number;
    unit_id: string;
    price_per_unit: number;
    currency_code?: string;
    line_total: number;
  }>,
) {
  const { data: order, error: orderError } = await supabase
    .from('orders')
    .insert(orderData)
    .select()
    .single();

  if (orderError) return { data: null, error: orderError };

  const itemsWithOrderId = items.map((item) => ({
    ...item,
    order_id: order.id,
  }));

  const { error: itemsError } = await supabase
    .from('order_items')
    .insert(itemsWithOrderId);

  if (itemsError) return { data: null, error: itemsError };

  return getOrderById(order.id);
}

/** Update order status. */
export async function updateOrderStatus(orderId: string, status: string) {
  const { data, error } = await supabase
    .from('orders')
    .update({ status, updated_at: new Date().toISOString() })
    .eq('id', orderId)
    .select()
    .single();
  return { data, error };
}

/** Update payment status. */
export async function updatePaymentStatus(orderId: string, status: string, method?: string) {
  const updates: Record<string, unknown> = {
    payment_status: status,
    updated_at: new Date().toISOString(),
  };
  if (method) updates.payment_method = method;

  const { data, error } = await supabase
    .from('orders')
    .update(updates)
    .eq('id', orderId)
    .select()
    .single();
  return { data, error };
}

/** Store confirms order receipt. */
export async function confirmOrderReceipt(orderId: string, data: {
  actual_qty_received?: number;
  store_notes?: string;
}) {
  const { data: order, error } = await supabase
    .from('orders')
    .update({
      status: 'confirmed',
      actual_qty_received: data.actual_qty_received,
      store_notes: data.store_notes,
      updated_at: new Date().toISOString(),
    })
    .eq('id', orderId)
    .select()
    .single();
  return { data: order, error };
}

/** Get user's orders by role with filters. */
export async function getMyOrders(userId: string, role: 'farmer' | 'store', filters?: {
  status?: string;
  source?: string;
  page?: number;
  pageSize?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}) {
  const page = filters?.page ?? 1;
  const pageSize = filters?.pageSize ?? DEFAULT_PAGE_SIZE;
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  const roleColumn = role === 'farmer' ? 'farmer_id' : 'store_id';

  let query = supabase
    .from('orders')
    .select('*, items:order_items(*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*)), farmer:farmers(*, profile:profiles(*)), store:stores(*, profile:profiles(*))', { count: 'exact' })
    .eq(roleColumn, userId)
    .range(from, to);

  if (filters?.status) {
    query = query.eq('status', filters.status);
  }
  if (filters?.source) {
    query = query.eq('source', filters.source);
  }

  const sortBy = filters?.sortBy ?? 'created_at';
  const sortOrder = filters?.sortOrder ?? 'desc';
  query = query.order(sortBy, { ascending: sortOrder === 'asc' });

  const { data, error, count } = await query;
  return { data, error, count };
}

/** Get single order with all joins. */
export async function getOrderById(orderId: string) {
  const { data, error } = await supabase
    .from('orders')
    .select('*, items:order_items(*, product:products(*), variety:product_varieties(*), unit:units_of_measure(*)), farmer:farmers(*, profile:profiles(*)), store:stores(*, profile:profiles(*)), review:reviews(*)')
    .eq('id', orderId)
    .single();
  return { data, error };
}

/** Admin: get all orders with filters. */
export async function getAllOrders(filters?: {
  status?: string;
  source?: string;
  page?: number;
  pageSize?: number;
}) {
  const page = filters?.page ?? 1;
  const pageSize = filters?.pageSize ?? DEFAULT_PAGE_SIZE;
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  let query = supabase
    .from('orders')
    .select('*, items:order_items(*), farmer:farmers(*, profile:profiles(*)), store:stores(*, profile:profiles(*))', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to);

  if (filters?.status) {
    query = query.eq('status', filters.status);
  }
  if (filters?.source) {
    query = query.eq('source', filters.source);
  }

  const { data, error, count } = await query;
  return { data, error, count };
}
