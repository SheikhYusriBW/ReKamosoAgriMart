import { supabase } from '../client';

/** Farmer submits an offer on a tender. */
export async function createTenderOffer(data: {
  tender_id: string;
  farmer_id: string;
  quantity_offered: number;
  price_per_unit: number;
  currency_code?: string;
  delivery_date: string;
  delivery_method?: string;
  notes?: string | null;
}) {
  const { data: offer, error } = await supabase
    .from('tender_offers')
    .insert(data)
    .select('*, farmer:farmers(*, profile:profiles(*))')
    .single();
  return { data: offer, error };
}

/** Farmer withdraws their pending offer. */
export async function withdrawTenderOffer(offerId: string) {
  const { error } = await supabase
    .from('tender_offers')
    .delete()
    .eq('id', offerId)
    .eq('status', 'pending');
  return { error };
}

/** Store: get all offers on their tender with farmer info. */
export async function getOffersForTender(tenderId: string) {
  const { data, error } = await supabase
    .from('tender_offers')
    .select('*, farmer:farmers(*, profile:profiles(*))')
    .eq('tender_id', tenderId)
    .order('created_at', { ascending: true });
  return { data, error };
}

/** Farmer: get all their tender offers. */
export async function getMyTenderOffers(farmerId: string) {
  const { data, error } = await supabase
    .from('tender_offers')
    .select('*, tender:tenders(*, product:products(*), store:stores(*, profile:profiles(*)))')
    .eq('farmer_id', farmerId)
    .order('created_at', { ascending: false });
  return { data, error };
}

/** Store accepts a tender offer. */
export async function acceptTenderOffer(offerId: string) {
  const { data, error } = await supabase
    .from('tender_offers')
    .update({
      status: 'accepted',
      responded_at: new Date().toISOString(),
    })
    .eq('id', offerId)
    .select('*, farmer:farmers(*, profile:profiles(*)), tender:tenders(*)')
    .single();
  return { data, error };
}

/** Store declines a tender offer. */
export async function declineTenderOffer(offerId: string) {
  const { data, error } = await supabase
    .from('tender_offers')
    .update({
      status: 'declined',
      responded_at: new Date().toISOString(),
    })
    .eq('id', offerId)
    .select()
    .single();
  return { data, error };
}
