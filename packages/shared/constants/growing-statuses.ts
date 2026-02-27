export const GROWING_STATUSES = {
  PLANTED: 'planted',
  GROWING: 'growing',
  APPROACHING_HARVEST: 'approaching_harvest',
  READY: 'ready',
  HARVESTED: 'harvested',
} as const;

export const GROWING_STATUS_LABELS: Record<string, string> = {
  planted: 'Planted',
  growing: 'Growing',
  approaching_harvest: 'Approaching Harvest',
  ready: 'Ready to Harvest',
  harvested: 'Harvested',
};

export const GROWING_STATUS_COLORS: Record<string, string> = {
  planted: '#8B5CF6',
  growing: '#22C55E',
  approaching_harvest: '#F97316',
  ready: '#EAB308',
  harvested: '#16A34A',
};
