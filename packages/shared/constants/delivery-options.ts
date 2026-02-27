export const DELIVERY_OPTIONS = {
  FARMER_DELIVERS: 'farmer_delivers',
  STORE_COLLECTS: 'store_collects',
  EITHER: 'either',
} as const;

export const DELIVERY_OPTION_LABELS: Record<string, string> = {
  farmer_delivers: 'Farmer Delivers',
  store_collects: 'Store Collects',
  either: 'Either',
};
