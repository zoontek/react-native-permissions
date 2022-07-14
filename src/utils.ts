import {Platform} from 'react-native';

export const platformVersion =
  typeof Platform.Version === 'string' ? parseInt(Platform.Version, 10) : Platform.Version;

export function uniq<T>(array: T[]): T[] {
  return array.filter((item, index) => item != null && array.indexOf(item) === index);
}
