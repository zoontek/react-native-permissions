import {NativeModules} from 'react-native';
import type {Contract} from './contract';
import type {NotificationsResponse, Permission, PermissionStatus} from './types';
import {
  checkLocationAccuracy,
  openPhotoPicker,
  requestLocationAccuracy,
} from './unsupportedPlatformMethods';
import {uniq} from './utils';

const NativeModule: {
  Check: (permission: Permission) => Promise<PermissionStatus>;
  CheckNotifications: () => Promise<PermissionStatus>;
  Request: (permission: Permission) => Promise<PermissionStatus>;
  OpenSettings: () => Promise<void>;
} = NativeModules.RNPermissions;

async function openSettings(): Promise<void> {
  await NativeModule.OpenSettings();
}

function check(permission: Permission): Promise<PermissionStatus> {
  return NativeModule.Check(permission);
}

function request(permission: Permission): Promise<PermissionStatus> {
  return NativeModule.Request(permission);
}

async function checkNotifications(): Promise<NotificationsResponse> {
  return {status: await NativeModule.CheckNotifications(), settings: {}};
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
  requestNotifications: checkNotifications,
};
