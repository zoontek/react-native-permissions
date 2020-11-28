export function uniq<T>(array: T[]): T[] {
  return array.filter((item, index) => item != null && array.indexOf(item) === index);
}
