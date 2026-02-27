/** Format a date string to readable format. formatDate('2025-03-15T10:30:00Z') -> "15 Mar 2025" */
export function formatDate(dateString: string): string {
  const date = new Date(dateString);
  return date.toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  });
}

/** Format to relative time: "2 hours ago", "3 days ago", "just now" */
export function timeAgo(dateString: string): string {
  const now = new Date();
  const date = new Date(dateString);
  const seconds = Math.floor((now.getTime() - date.getTime()) / 1000);

  if (seconds < 60) return 'just now';
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d ago`;
  const weeks = Math.floor(days / 7);
  if (weeks < 4) return `${weeks}w ago`;
  return formatDate(dateString);
}

/** Format date range: "15 Mar - 20 Apr 2025" */
export function formatDateRange(from: string, to: string): string {
  const fromDate = new Date(from);
  const toDate = new Date(to);
  const fromStr = fromDate.toLocaleDateString('en-GB', { day: 'numeric', month: 'short' });
  const toStr = toDate.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
  return `${fromStr} \u2014 ${toStr}`;
}

/** Days remaining until a date. Returns negative if past. */
export function daysUntil(dateString: string): number {
  const now = new Date();
  const target = new Date(dateString);
  const diff = target.getTime() - now.getTime();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
}

/** Check if a date is in the past. */
export function isPast(dateString: string): boolean {
  return new Date(dateString) < new Date();
}
