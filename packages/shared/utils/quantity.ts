/** Format quantity with unit abbreviation. formatQuantity(500, { abbreviation: 'kg' }) -> "500 kg" */
export function formatQuantity(amount: number, unit: { abbreviation: string }): string {
  const formatted = parseFloat(amount.toFixed(2)).toString();
  return `${formatted} ${unit.abbreviation}`;
}

/** Format quantity remaining vs total: "350 / 500 kg" */
export function formatQuantityProgress(remaining: number, total: number, unit: { abbreviation: string }): string {
  const r = parseFloat(remaining.toFixed(2));
  const t = parseFloat(total.toFixed(2));
  return `${r} / ${t} ${unit.abbreviation}`;
}

/** Calculate percentage remaining. */
export function quantityPercentage(remaining: number, total: number): number {
  if (total <= 0) return 0;
  return Math.round((remaining / total) * 100);
}
