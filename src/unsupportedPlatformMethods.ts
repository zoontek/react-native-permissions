import type {LocationAccuracy, LocationAccuracyOptions} from './types';

const IOS_14 = 'Only supported by iOS 14 and above';

export async function checkLocationAccuracy(): Promise<LocationAccuracy> {
  throw new Error(IOS_14);
}

export async function requestLocationAccuracy(
  _options: LocationAccuracyOptions,
): Promise<LocationAccuracy> {
  throw new Error(IOS_14);
}

export async function openLimitedPhotoLibraryPicker(): Promise<void> {
  throw new Error(IOS_14);
}
