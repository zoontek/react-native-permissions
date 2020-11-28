import {NativeModules} from 'react-native';
import type {Contract} from './contract';
import {RESULTS} from './results';
import type {
  LocationAccuracy,
  LocationAccuracyOptions,
  NotificationOption,
  NotificationsResponse,
  Permission,
  PermissionStatus,
} from './types';
import {uniq} from './utils';

const NativeModule: {
  available: Permission[];

  check: (permission: Permission) => Promise<PermissionStatus>;
  checkLocationAccuracy: () => Promise<LocationAccuracy>;
  checkNotifications: () => Promise<NotificationsResponse>;
  openLimitedPhotoLibraryPicker: () => Promise<true>;
  openSettings: () => Promise<true>;
  request: (permission: Permission, options?: object) => Promise<PermissionStatus>;
  requestLocationAccuracy: (purposeKey: string) => Promise<LocationAccuracy>;
  requestNotifications: (options: NotificationOption[]) => Promise<NotificationsResponse>;
} = NativeModules.RNPermissions;

async function openLimitedPhotoLibraryPicker(): Promise<void> {
  await NativeModule.openLimitedPhotoLibraryPicker();
}

async function openSettings(): Promise<void> {
  await NativeModule.openSettings();
}

async function check(permission: Permission): Promise<PermissionStatus> {
  return NativeModule.available.includes(permission)
    ? NativeModule.check(permission)
    : RESULTS.UNAVAILABLE;
}

async function request(permission: Permission): Promise<PermissionStatus> {
  return NativeModule.available.includes(permission)
    ? NativeModule.request(permission)
    : RESULTS.UNAVAILABLE;
}

function checkLocationAccuracy(): Promise<LocationAccuracy> {
  return NativeModule.checkLocationAccuracy();
}

function requestLocationAccuracy(options: LocationAccuracyOptions): Promise<LocationAccuracy> {
  return NativeModule.requestLocationAccuracy(options.purposeKey);
}

export function checkNotifications(): Promise<NotificationsResponse> {
  return NativeModule.checkNotifications();
}

export function requestNotifications(
  options: NotificationOption[],
): Promise<NotificationsResponse> {
  return NativeModule.requestNotifications(options);
}

async function checkMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  type Output = Record<P[number], PermissionStatus>;

  const output: Partial<Output> = {};
  const dedup = uniq(permissions);

  await Promise.all(
    dedup.map(async (permission: P[number]) => {
      output[permission] = await check(permission);
    }),
  );

  return output as Output;
}

async function requestMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  type Output = Record<P[number], PermissionStatus>;

  const output: Partial<Output> = {};
  const dedup = uniq(permissions);

  for (let index = 0; index < dedup.length; index++) {
    const permission: P[number] = dedup[index];
    output[permission] = await request(permission);
  }

  return output as Output;
}

export const methods: Contract = {
  check,
  checkLocationAccuracy,
  checkMultiple,
  checkNotifications,
  openLimitedPhotoLibraryPicker,
  openSettings,
  request,
  requestLocationAccuracy,
  requestMultiple,
  requestNotifications,
};
