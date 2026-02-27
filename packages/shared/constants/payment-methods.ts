export const PAYMENT_METHODS = {
  CASH: 'cash',
  EFT: 'eft',
  OTHER: 'other',
} as const;

export const PAYMENT_METHOD_LABELS: Record<string, string> = {
  cash: 'Cash',
  eft: 'EFT / Bank Transfer',
  other: 'Other',
};
