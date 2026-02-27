export const CONTRACT_STATUSES = {
  OPEN: 'open',
  ACCEPTED: 'accepted',
  ACTIVE: 'active',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
} as const;

export const CONTRACT_STATUS_LABELS: Record<string, string> = {
  open: 'Open',
  accepted: 'Accepted',
  active: 'Active',
  completed: 'Completed',
  cancelled: 'Cancelled',
};

export const CONTRACT_STATUS_COLORS: Record<string, string> = {
  open: '#3B82F6',
  accepted: '#6366F1',
  active: '#22C55E',
  completed: '#16A34A',
  cancelled: '#EF4444',
};
