export const RESULTS = Object.freeze({
  BLOCKED: 'blocked',
  DENIED: 'denied',
  GRANTED: 'granted',
  LIMITED: 'limited',
} as const);

export type ResultMap = typeof RESULTS;
