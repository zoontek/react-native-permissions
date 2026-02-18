import type {Contract} from '../contract';
import {PERMISSIONS as PERMISSIONS_ANDROID} from '../permissions.android';
import {PERMISSIONS as PERMISSIONS_IOS} from '../permissions.ios';
import {PERMISSIONS as PERMISSIONS_WINDOWS} from '../permissions.windows';
import {RESULTS} from '../results';
import type {PermissionStatus} from '../types';

const PERMISSIONS = {
  ANDROID: PERMISSIONS_ANDROID,
  IOS: PERMISSIONS_IOS,
  WINDOWS: PERMISSIONS_WINDOWS,
};

export {PERMISSIONS, RESULTS};

export const canScheduleExactAlarms = jest.fn(async () => true);
export const canUseFullScreenIntent = jest.fn(async () => true);
export const check = jest.fn(async () => RESULTS.GRANTED);
export const checkLocationAccuracy = jest.fn(async () => 'full');
export const openPhotoPicker = jest.fn(async () => {});
export const openSettings = jest.fn(async () => {});
export const request = jest.fn(async () => RESULTS.GRANTED);
export const requestLocationAccuracy = jest.fn(async () => 'full');

const notificationOptions = new Set([
  'alert',
  'badge',
  'sound',
  'carPlay',
  'criticalAlert',
  'provisional',
  'providesAppSettings',
]);

const notificationSettings = {
  alert: true,
  badge: true,
  sound: true,
  carPlay: true,
  criticalAlert: true,
  provisional: true,
  providesAppSettings: true,
  lockScreen: true,
  notificationCenter: true,
};

export const checkNotifications: Contract['checkNotifications'] = jest.fn(async () => ({
  status: RESULTS.GRANTED,
  settings: notificationSettings,
}));

export const requestNotifications: Contract['requestNotifications'] = jest.fn(
  async (options = []) => ({
    status: RESULTS.GRANTED,
    settings: options
      .filter((option) => notificationOptions.has(option))
      .reduce((acc, option) => ({...acc, [option]: true}), {
        lockScreen: true,
        notificationCenter: true,
      }),
  }),
);

export const checkMultiple: Contract['checkMultiple'] = jest.fn(async (permissions) => {
  const output: Record<string, PermissionStatus> = {};

  for (const permission of permissions) {
    output[permission] = RESULTS.GRANTED;
  }

  return output as Awaited<ReturnType<Contract['checkMultiple']>>;
});

export const requestMultiple: Contract['requestMultiple'] = jest.fn(async (permissions) => {
  const output: Record<string, PermissionStatus> = {};

  for (const permission of permissions) {
    output[permission] = RESULTS.GRANTED;
  }

  return output as Awaited<ReturnType<Contract['requestMultiple']>>;
});

export default {
  PERMISSIONS,
  RESULTS,

  canScheduleExactAlarms,
  canUseFullScreenIntent,
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
