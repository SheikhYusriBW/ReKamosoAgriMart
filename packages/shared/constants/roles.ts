export const ROLES = {
  FARMER: 'farmer',
  STORE: 'store',
  ADMIN: 'admin',
} as const;

export const ROLE_LABELS: Record<string, string> = {
  farmer: 'Farmer',
  store: 'Store',
  admin: 'Admin',
};
