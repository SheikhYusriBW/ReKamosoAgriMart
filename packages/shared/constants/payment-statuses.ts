export const PAYMENT_STATUSES = {
  UNPAID: 'unpaid',
  PAID: 'paid',
  CONFIRMED: 'confirmed',
} as const;

export const PAYMENT_STATUS_LABELS: Record<string, string> = {
  unpaid: 'Unpaid',
  paid: 'Paid',
  confirmed: 'Payment Confirmed',
};

export const PAYMENT_STATUS_COLORS: Record<string, string> = {
  unpaid: '#EF4444',
  paid: '#F97316',
  confirmed: '#22C55E',
};
