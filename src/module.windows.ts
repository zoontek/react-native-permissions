import {NativeModules} from 'react-native';
import {RESULTS, PERMISSIONS} from './constants';
import {Contract} from './contract';
import {NotificationsResponse, Permission, PermissionStatus} from './types';
import {uniq} from './utils';

const RNP: {
  OpenSettings: () => Promise<void>;
  CheckNotifications: () => Promise<PermissionStatus>;
  Check: (permission: Permission) => Promise<PermissionStatus>;
  Request: (permission: Permission) => Promise<PermissionStatus>;
} = NativeModules.RNPermissions;

async function openSettings(): Promise<void> {
  return RNP.OpenSettings();
}

async function check(permission: Permission): Promise<PermissionStatus> {
  return RNP.Check(permission);
}

async function request(permission: Permission): Promise<PermissionStatus> {
  return RNP.Request(permission);
}

async function checkNotifications(): Promise<NotificationsResponse> {
  const status = await RNP.CheckNotifications();
  return {status, settings: {}};
}

async function requestNotifications(): Promise<NotificationsResponse> {
  // There is no way to request notifications on Windows if they are
  // disabled.
  return checkNotifications();
}

async function checkMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  const result = {} as Record<P[number], PermissionStatus>;
  const promises = permissions.map(async (permission: P[number]) => {
    const promise = check(permission);
    result[permission] = await promise;
    return promise;
  });
  Promise.all(promises);
  return result;
}

async function requestMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  const result = {} as Record<P[number], PermissionStatus>;
  const promises = permissions.map(async (permission: P[number]) => {
    const promise = request(permission);
    result[permission] = await promise;
    return promise;
  });
  Promise.all(promises);
  return result;
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
