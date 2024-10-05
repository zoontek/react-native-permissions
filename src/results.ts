export const RESULTS = Object.freeze({
  UNAVAILABLE: 'unavailable',
  BLOCKED: 'blocked',
  DENIED: 'denied',
  GRANTED: 'granted',
  LIMITED: 'limited',
} as const);

export type ResultMap = typeof RESULTS;
