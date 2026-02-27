export const VERIFICATION_STATUSES = {
  PENDING: 'pending',
  APPROVED: 'approved',
  REJECTED: 'rejected',
  SUSPENDED: 'suspended',
} as const;

export const VERIFICATION_STATUS_LABELS: Record<string, string> = {
  pending: 'Pending Review',
  approved: 'Approved',
  rejected: 'Rejected',
  suspended: 'Suspended',
};

export const VERIFICATION_STATUS_COLORS: Record<string, string> = {
  pending: '#F97316',
  approved: '#22C55E',
  rejected: '#EF4444',
  suspended: '#9CA3AF',
};
