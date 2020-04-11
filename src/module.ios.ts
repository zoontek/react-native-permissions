import {NativeModules} from 'react-native';
import {RESULTS, PERMISSIONS} from './constants';
import {Contract} from './contract';
import {
  NotificationOption,
  NotificationsResponse,
  Permission,
  PermissionStatus,
} from './types';
import {uniq} from './utils';

const RNP: {
  available: Permission[];

  checkNotifications: () => Promise<NotificationsResponse>;
  requestNotifications: (
    options: NotificationOption[],
  ) => Promise<NotificationsResponse>;
  openSettings: () => Promise<true>;
  check: (permission: Permission) => Promise<PermissionStatus>;
  request: (permission: Permission) => Promise<PermissionStatus>;
} = NativeModules.RNPermissions;

async function openSettings(): Promise<void> {
  await RNP.openSettings();
}

async function check(permission: Permission): Promise<PermissionStatus> {
  return RNP.available.includes(permission)
    ? RNP.check(permission)
    : RESULTS.UNAVAILABLE;
}

async function request(permission: Permission): Promise<PermissionStatus> {
  return RNP.available.includes(permission)
    ? RNP.request(permission)
    : RESULTS.UNAVAILABLE;
}

export function checkNotifications(): Promise<NotificationsResponse> {
  return RNP.checkNotifications();
}

export function requestNotifications(
  options: NotificationOption[],
): Promise<NotificationsResponse> {
  return RNP.requestNotifications(options);
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

export const module: Contract = {
  openSettings,
  check,
  request,
  checkNotifications,
  requestNotifications,
  checkMultiple,
  requestMultiple,
};
