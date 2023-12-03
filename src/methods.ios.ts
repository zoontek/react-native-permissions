import type {Contract} from './contract';
import NativeModule from './NativePermissionsModule';
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

let available: string[] | undefined = undefined;

function getAvailable(): string[] | undefined {
  if (available == null) {
    available = NativeModule.getConstants().available;
  }

  return available;
}

async function openPhotoPicker(): Promise<void> {
  await NativeModule.openPhotoPicker();
}

async function openSettings(): Promise<void> {
  await NativeModule.openSettings();
}

async function check(permission: Permission): Promise<PermissionStatus> {
  return getAvailable()?.includes(permission)
    ? (NativeModule.check(permission) as Promise<PermissionStatus>)
    : RESULTS.UNAVAILABLE;
}

async function request(permission: Permission): Promise<PermissionStatus> {
  return getAvailable()?.includes(permission)
    ? (NativeModule.request(permission) as Promise<PermissionStatus>)
    : RESULTS.UNAVAILABLE;
}

function checkLocationAccuracy(): Promise<LocationAccuracy> {
  return NativeModule.checkLocationAccuracy() as Promise<LocationAccuracy>;
}

function requestLocationAccuracy(options: LocationAccuracyOptions): Promise<LocationAccuracy> {
  return NativeModule.requestLocationAccuracy(options.purposeKey) as Promise<LocationAccuracy>;
}

export function checkNotifications(): Promise<NotificationsResponse> {
  return NativeModule.checkNotifications() as Promise<NotificationsResponse>;
}

export function requestNotifications(
  options: NotificationOption[],
): Promise<NotificationsResponse> {
  return NativeModule.requestNotifications(options) as Promise<NotificationsResponse>;
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
  openPhotoPicker,
  openSettings,
  request,
  requestLocationAccuracy,
  requestMultiple,
  requestNotifications,
};
