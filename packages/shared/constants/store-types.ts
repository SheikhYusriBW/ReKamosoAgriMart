export const STORE_TYPES = {
  GROCERY: 'grocery',
  DEPO: 'depo',
  RESTAURANT: 'restaurant',
  HOTEL: 'hotel',
  OTHER: 'other',
} as const;

export const STORE_TYPE_LABELS: Record<string, string> = {
  grocery: 'Grocery Store',
  depo: 'Depo / Wholesale',
  restaurant: 'Restaurant',
  hotel: 'Hotel',
  other: 'Other',
};
