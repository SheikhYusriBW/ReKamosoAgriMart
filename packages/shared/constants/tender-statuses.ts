export const TENDER_STATUSES = {
  ACTIVE: 'active',
  FULFILLED: 'fulfilled',
  EXPIRED: 'expired',
  CANCELLED: 'cancelled',
} as const;

export const TENDER_STATUS_LABELS: Record<string, string> = {
  active: 'Active',
  fulfilled: 'Fulfilled',
  expired: 'Expired',
  cancelled: 'Cancelled',
};

export const TENDER_STATUS_COLORS: Record<string, string> = {
  active: '#22C55E',
  fulfilled: '#3B82F6',
  expired: '#F97316',
  cancelled: '#EF4444',
};
