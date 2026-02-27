import type { Currency } from '../types';

/** Format a price with currency symbol. formatPrice(50, { symbol: 'P', decimal_precision: 2 }) -> "P50.00" */
export function formatPrice(amount: number, currency: { symbol: string; decimal_precision: number }): string {
  const formatted = amount.toLocaleString('en-US', {
    minimumFractionDigits: currency.decimal_precision,
    maximumFractionDigits: currency.decimal_precision,
  });
  return `${currency.symbol}${formatted}`;
}

/** Shorthand when you have the full currency object. */
export function formatPriceWithCurrency(amount: number, currency: Currency): string {
  return formatPrice(amount, {
    symbol: currency.symbol,
    decimal_precision: currency.decimal_precision,
  });
}

/** Default BWP formatting. */
export function formatBWP(amount: number): string {
  return formatPrice(amount, { symbol: 'P', decimal_precision: 2 });
}
