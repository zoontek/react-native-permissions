export const proxifyPermissions = <T extends Record<string, string>>(
  platform: 'android' | 'ios' | 'windows',
) =>
  new Proxy({} as T, {
    get: (_, prop) => (typeof prop === 'string' ? `${platform}.permission.${prop}` : prop),
  });

export const uniq = <T>(array: T[]): T[] => {
  return array.filter((item, index) => item != null && array.indexOf(item) === index);
};
