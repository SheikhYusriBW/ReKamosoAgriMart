export const CONTRACT_DELIVERY_STATUSES = {
  UPCOMING: 'upcoming',
  DUE: 'due',
  DELIVERED: 'delivered',
  CONFIRMED: 'confirmed',
  MISSED: 'missed',
} as const;

export const CONTRACT_DELIVERY_STATUS_LABELS: Record<string, string> = {
  upcoming: 'Upcoming',
  due: 'Due',
  delivered: 'Delivered',
  confirmed: 'Confirmed',
  missed: 'Missed',
};

export const CONTRACT_DELIVERY_STATUS_COLORS: Record<string, string> = {
  upcoming: '#3B82F6',
  due: '#F97316',
  delivered: '#22C55E',
  confirmed: '#16A34A',
  missed: '#EF4444',
};
