import type {LocationAccuracy, LocationAccuracyOptions} from './types';

const IOS_14 = 'Only supported by iOS 14 and above';
const ANDROID_23 = 'Only supported by Android 23 and above';

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

export async function checkBatteryOptimizationPermission(): Promise<Boolean> {
  throw new Error(ANDROID_23);
}

export async function triggerBatteryOptimizationNativeDialog(): Promise<void> {
  throw new Error(ANDROID_23);
}