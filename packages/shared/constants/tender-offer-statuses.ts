export const TENDER_OFFER_STATUSES = {
  PENDING: 'pending',
  ACCEPTED: 'accepted',
  DECLINED: 'declined',
} as const;

export const TENDER_OFFER_STATUS_LABELS: Record<string, string> = {
  pending: 'Pending',
  accepted: 'Accepted',
  declined: 'Declined',
};

export const TENDER_OFFER_STATUS_COLORS: Record<string, string> = {
  pending: '#F97316',
  accepted: '#22C55E',
  declined: '#EF4444',
};
