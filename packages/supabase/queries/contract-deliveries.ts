import { supabase } from '../client';

/** Get all deliveries for a contract. */
export async function getDeliveriesForContract(contractId: string) {
  const { data, error } = await supabase
    .from('contract_deliveries')
    .select('*')
    .eq('contract_id', contractId)
    .order('expected_date', { ascending: true });
  return { data, error };
}

/** Farmer logs a delivery. */
export async function logDelivery(deliveryId: string, data: {
  actual_date: string;
  actual_quantity: number;
  farmer_notes?: string;
}) {
  const { data: delivery, error } = await supabase
    .from('contract_deliveries')
    .update({
      actual_date: data.actual_date,
      actual_quantity: data.actual_quantity,
      farmer_notes: data.farmer_notes,
      status: 'delivered',
      updated_at: new Date().toISOString(),
    })
    .eq('id', deliveryId)
    .select()
    .single();
  return { data: delivery, error };
}

/** Store confirms a delivery. */
export async function confirmDelivery(deliveryId: string, data: {
  quality_rating?: number;
  store_notes?: string;
}) {
  const { data: delivery, error } = await supabase
    .from('contract_deliveries')
    .update({
      quality_rating: data.quality_rating,
      store_notes: data.store_notes,
      status: 'confirmed',
      updated_at: new Date().toISOString(),
    })
    .eq('id', deliveryId)
    .select()
    .single();
  return { data: delivery, error };
}

/** Atomically update contract delivery totals. MUST use RPC — never direct update. */
export async function updateContractDeliveryTotals(contractId: string, quantity: number) {
  const { data, error } = await supabase.rpc('update_contract_delivery_totals', {
    p_contract_id: contractId,
    p_qty: quantity,
  });
  return { data, error };
}
