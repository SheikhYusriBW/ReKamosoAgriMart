export const DELIVERY_METHODS = {
  FARMER_DELIVERS: 'farmer_delivers',
  STORE_COLLECTS: 'store_collects',
  THIRD_PARTY: 'third_party',
} as const;

export const DELIVERY_METHOD_LABELS: Record<string, string> = {
  farmer_delivers: 'Farmer Delivers',
  store_collects: 'Store Collects',
  third_party: 'Third Party',
};
