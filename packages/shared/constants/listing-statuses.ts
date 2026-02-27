export const LISTING_STATUSES = {
  DRAFT: 'draft',
  ACTIVE: 'active',
  SOLD: 'sold',
  EXPIRED: 'expired',
  CANCELLED: 'cancelled',
} as const;

export const LISTING_STATUS_LABELS: Record<string, string> = {
  draft: 'Draft',
  active: 'Active',
  sold: 'Sold Out',
  expired: 'Expired',
  cancelled: 'Cancelled',
};

export const LISTING_STATUS_COLORS: Record<string, string> = {
  draft: '#9CA3AF',
  active: '#22C55E',
  sold: '#3B82F6',
  expired: '#F97316',
  cancelled: '#EF4444',
};
