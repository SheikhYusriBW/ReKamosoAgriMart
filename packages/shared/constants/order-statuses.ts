export const ORDER_STATUSES = {
  NEW: 'new',
  ACCEPTED: 'accepted',
  PREPARING: 'preparing',
  READY: 'ready',
  IN_TRANSIT: 'in_transit',
  DELIVERED: 'delivered',
  CONFIRMED: 'confirmed',
  CANCELLED: 'cancelled',
} as const;

export const ORDER_STATUS_LABELS: Record<string, string> = {
  new: 'New',
  accepted: 'Accepted',
  preparing: 'Preparing',
  ready: 'Ready for Pickup',
  in_transit: 'In Transit',
  delivered: 'Delivered',
  confirmed: 'Confirmed',
  cancelled: 'Cancelled',
};

export const ORDER_STATUS_COLORS: Record<string, string> = {
  new: '#3B82F6',
  accepted: '#6366F1',
  preparing: '#8B5CF6',
  ready: '#0EA5E9',
  in_transit: '#F97316',
  delivered: '#22C55E',
  confirmed: '#16A34A',
  cancelled: '#EF4444',
};
